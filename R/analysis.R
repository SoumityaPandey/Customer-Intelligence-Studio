suppressPackageStartupMessages(library(dplyr))
clean_retail_data <- function(path) {
  data <- read.csv(path, stringsAsFactors = FALSE, check.names = FALSE,
                   na.strings = c("", "NA"), fileEncoding = "latin1")
  names(data) <- trimws(names(data))
  data$InvoiceNo <- as.character(data$InvoiceNo)
  data$CustomerID <- as.character(data$CustomerID)
  data$InvoiceDate <- lubridate::mdy_hm(data$InvoiceDate, quiet = TRUE)
  data$Quantity <- as.numeric(data$Quantity)
  data$UnitPrice <- as.numeric(data$UnitPrice)
  data <- data %>%
    dplyr::filter(
      !is.na(CustomerID),
      !is.na(InvoiceDate),
      Quantity > 0,
      UnitPrice > 0,
      !grepl("^C", InvoiceNo, ignore.case = TRUE)
    ) %>%
    dplyr::mutate(TotalAmount = Quantity * UnitPrice)
  data
}

calculate_kpis <- function(data) {
  orders <- dplyr::n_distinct(data$InvoiceNo)
  customers <- dplyr::n_distinct(data$CustomerID)
  revenue <- sum(data$TotalAmount, na.rm = TRUE)
  units <- sum(data$Quantity, na.rm = TRUE)
  customer_orders <- data %>% dplyr::distinct(CustomerID, InvoiceNo) %>% dplyr::count(CustomerID, name = "Orders")
  repeat_rate <- mean(customer_orders$Orders > 1) * 100
  list(
    revenue = revenue,
    customers = customers,
    orders = orders,
    units = units,
    aov = ifelse(orders > 0, revenue / orders, 0),
    revenue_per_customer = ifelse(customers > 0, revenue / customers, 0),
    repeat_rate = repeat_rate,
    first_date = min(data$InvoiceDate),
    last_date = max(data$InvoiceDate)
  )
}

create_rfm <- function(data) {
  reference_date <- max(data$InvoiceDate, na.rm = TRUE) + lubridate::days(1)
  rfm <- data %>%
    dplyr::group_by(CustomerID) %>%
    dplyr::summarise(
      Recency = as.numeric(reference_date - max(InvoiceDate)),
      Frequency = dplyr::n_distinct(InvoiceNo),
      Monetary = sum(TotalAmount, na.rm = TRUE),
      AverageOrderValue = Monetary / Frequency,
      LastPurchase = max(InvoiceDate),
      Country = dplyr::first(Country),
      .groups = "drop"
    ) %>%
    dplyr::mutate(
      R_Score = dplyr::ntile(dplyr::desc(Recency), 5),
      F_Score = dplyr::ntile(Frequency, 5),
      M_Score = dplyr::ntile(Monetary, 5),
      RFM_Score = R_Score + F_Score + M_Score,
      Segment = dplyr::case_when(
        RFM_Score >= 13 ~ "Champions",
        RFM_Score >= 10 ~ "Loyal Customers",
        RFM_Score >= 7 ~ "Potential Customers",
        RFM_Score >= 5 ~ "At Risk Customers",
        TRUE ~ "Lost Customers"
      ),
      Personality = dplyr::case_when(
        RFM_Score >= 13 ~ "VIP Shopper",
        R_Score >= 4 & F_Score >= 4 ~ "Loyal Shopper",
        M_Score >= 4 & F_Score <= 2 ~ "Big Spender",
        R_Score >= 4 & F_Score <= 2 ~ "Promising Shopper",
        R_Score <= 2 & M_Score >= 4 ~ "Sleeping Giant",
        TRUE ~ "Dormant Shopper"
      )
    )
  rfm
}

find_optimal_k <- function(rfm, k_values = 2:6) {
  x <- scale(log1p(rfm[, c("Recency", "Frequency", "Monetary")]))
  scores <- data.frame(K = k_values, Silhouette = NA_real_)
  models <- vector("list", length(k_values))
  for (i in seq_along(k_values)) {
    set.seed(123)
    fit <- stats::kmeans(x, centers = k_values[i], nstart = 20)
    sil <- cluster::silhouette(fit$cluster, stats::dist(x))
    scores$Silhouette[i] <- mean(sil[, 3])
    models[[i]] <- fit
  }
  best_index <- which.max(scores$Silhouette)
  list(scores = scores, best_k = scores$K[best_index], model = models[[best_index]], scaled = x)
}

apply_kmeans <- function(rfm, optimal) {
  out <- rfm
  out$Cluster <- factor(optimal$model$cluster)
  centers <- as.data.frame(optimal$model$centers)
  centers$Cluster <- factor(seq_len(nrow(centers)))
  list(data = out, centers = centers)
}

create_cohort_data <- function(data) {
  monthly <- data %>%
    dplyr::mutate(OrderMonth = lubridate::floor_date(InvoiceDate, "month")) %>%
    dplyr::group_by(CustomerID) %>%
    dplyr::mutate(CohortMonth = min(OrderMonth)) %>%
    dplyr::ungroup() %>%
    dplyr::distinct(CustomerID, OrderMonth, CohortMonth)
  counts <- monthly %>%
    dplyr::group_by(CohortMonth, OrderMonth) %>%
    dplyr::summarise(Customers = dplyr::n_distinct(CustomerID), .groups = "drop") %>%
    dplyr::mutate(MonthNumber = 12 * (lubridate::year(OrderMonth) - lubridate::year(CohortMonth)) +
                    (lubridate::month(OrderMonth) - lubridate::month(CohortMonth)))
  cohort_sizes <- counts %>% dplyr::filter(MonthNumber == 0) %>% dplyr::select(CohortMonth, CohortSize = Customers)
  counts %>%
    dplyr::left_join(cohort_sizes, by = "CohortMonth") %>%
    dplyr::mutate(Retention = Customers / CohortSize * 100)
}

product_summary <- function(data) {
  data %>%
    dplyr::mutate(Product = ifelse(is.na(Description) | Description == "", StockCode, Description)) %>%
    dplyr::group_by(StockCode, Product) %>%
    dplyr::summarise(
      Revenue = sum(TotalAmount), Units = sum(Quantity), Customers = dplyr::n_distinct(CustomerID),
      Orders = dplyr::n_distinct(InvoiceNo), .groups = "drop"
    ) %>%
    dplyr::arrange(dplyr::desc(Revenue))
}

country_summary <- function(data) {
  data %>% dplyr::group_by(Country) %>% dplyr::summarise(
    Revenue = sum(TotalAmount), Customers = dplyr::n_distinct(CustomerID),
    Orders = dplyr::n_distinct(InvoiceNo), Units = sum(Quantity), .groups = "drop"
  ) %>% dplyr::arrange(dplyr::desc(Revenue))
}

monthly_summary <- function(data) {
  data %>% dplyr::mutate(Month = lubridate::floor_date(InvoiceDate, "month")) %>%
    dplyr::group_by(Month) %>% dplyr::summarise(
      Revenue = sum(TotalAmount), Orders = dplyr::n_distinct(InvoiceNo),
      Customers = dplyr::n_distinct(CustomerID), .groups = "drop"
    )
}

customer_purchase_history <- function(data, customer_id) {
  data %>% dplyr::filter(CustomerID == customer_id) %>%
    dplyr::group_by(InvoiceNo, InvoiceDate) %>%
    dplyr::summarise(
      Products = dplyr::n_distinct(StockCode), Units = sum(Quantity),
      OrderValue = sum(TotalAmount), .groups = "drop"
    ) %>% dplyr::arrange(dplyr::desc(InvoiceDate))
}

smart_insights <- function(data, rfm, countries) {
  top_country <- countries %>% dplyr::slice_max(Revenue, n = 1, with_ties = FALSE)
  top_segment <- rfm %>% dplyr::count(Segment, sort = TRUE) %>% dplyr::slice(1)
  at_risk <- sum(rfm$Segment %in% c("At Risk Customers", "Lost Customers"))
  repeat_rate <- calculate_kpis(data)$repeat_rate
  insights <- c(
    paste0("🌍 ", top_country$Country, " is the leading revenue market with £", scales::comma(round(top_country$Revenue)), "."),
    paste0("🏆 ", top_segment$Segment, " is the largest customer segment with ", top_segment$n, " customers."),
    paste0("⚠️ ", at_risk, " customers are currently classified as At Risk or Lost and may need re-engagement."),
    paste0("🔁 Approximately ", round(repeat_rate, 1), "% of customers placed more than one order."),
    paste0("💡 The dashboard can be used to prioritize retention efforts toward high-value customers before broad discounting.")
  )
  insights
}
