# Customer Intelligence Studio - Shiny Application
# Run from the project root with: shiny::runApp("app")

library(shiny)
library(bslib)
library(bsicons)
library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)
library(plotly)
library(DT)
library(scales)

source(file.path("..", "R", "analysis.R"))

DATA_PATH <- file.path("..", "data", "clean_retail_data.rds")

if (!file.exists(DATA_PATH)) {
  stop("clean_retail_data.rds was not found in the data folder.")
}

raw_data <- readRDS(DATA_PATH)
kpis <- calculate_kpis(raw_data)
rfm_base <- create_rfm(raw_data)
optimal <- find_optimal_k(rfm_base)
km <- apply_kmeans(rfm_base, optimal)
rfm <- km$data
monthly <- monthly_summary(raw_data)
products <- product_summary(raw_data)
countries <- country_summary(raw_data)
cohort <- create_cohort_data(raw_data)
insights <- smart_insights(raw_data, rfm, countries)

fmt_money <- function(x) {
  paste0("£", scales::comma(round(x)))
}

fmt_number <- function(x) {
  scales::comma(round(x))
}

server <- function(input, output, session) {

  # -----------------------------
  # Overview
  # -----------------------------
  output$overview_ui <- renderUI({
    kpi_cards <- list(
      list(label = "Revenue", value = fmt_money(kpis$revenue), icon = "currency-pound"),
      list(label = "Customers", value = fmt_number(kpis$customers), icon = "people"),
      list(label = "Orders", value = fmt_number(kpis$orders), icon = "cart-check"),
      list(label = "Average Order Value", value = fmt_money(kpis$aov), icon = "graph-up-arrow")
    )

    cards <- lapply(kpi_cards, function(x) {
      column(
        width = 3,
        div(
          class = "glass kpi",
          span(class = "kpi-icon", bs_icon(x$icon)),
          div(class = "kpi-label", x$label),
          div(class = "kpi-value", x$value)
        )
      )
    })

    div(
      class = "container-fluid",
      fluidRow(cards),
      br(),
      fluidRow(
        column(
          width = 8,
          div(
            class = "glass p-3",
            div(class = "section-title", "Revenue Pulse"),
            div(class = "section-subtitle", "Monthly revenue across the retail period"),
            plotlyOutput("revenue_plot", height = "330px")
          )
        ),
        column(
          width = 4,
          div(
            class = "glass p-3",
            div(class = "section-title", "Customer Segments"),
            div(class = "section-subtitle", "RFM-based customer distribution"),
            plotlyOutput("segment_plot", height = "330px")
          )
        )
      ),
      br(),
      fluidRow(
        column(
          width = 6,
          div(
            class = "glass p-3",
            div(class = "section-title", "Country Intelligence"),
            div(class = "section-subtitle", "Top revenue markets"),
            plotlyOutput("country_plot", height = "320px")
          )
        ),
        column(
          width = 6,
          div(
            class = "glass p-3",
            div(class = "section-title", "Cluster Lab"),
            div(
              class = "section-subtitle",
              paste0(
                "Best K = ", optimal$best_k,
                " | Silhouette = ", round(max(optimal$scores$Silhouette), 3)
              )
            ),
            plotlyOutput("cluster_plot", height = "320px")
          )
        )
      )
    )
  })

  output$revenue_plot <- renderPlotly({
    p <- ggplot(
      monthly,
      aes(
        x = Month,
        y = Revenue,
        text = paste0(
          "Month: ", format(Month, "%b %Y"),
          "<br>Revenue: ", fmt_money(Revenue)
        )
      )
    ) +
      geom_line(linewidth = 1.3, color = "#8b5cf6") +
      geom_point(color = "#06b6d4", size = 2.2) +
      scale_y_continuous(labels = scales::label_currency(prefix = "£", big.mark = ",")) +
      theme_minimal(base_size = 12) +
      theme(
        plot.background = element_rect(fill = "transparent", color = NA),
        panel.background = element_rect(fill = "transparent", color = NA),
        text = element_text(color = "white"),
        axis.text = element_text(color = "#a7afc2"),
        panel.grid = element_line(color = "white", alpha = 0.06)
      ) +
      labs(x = NULL, y = NULL)

    ggplotly(p, tooltip = "text") %>% config(displayModeBar = FALSE)
  })

  output$segment_plot <- renderPlotly({
    segment_data <- rfm %>% count(Segment, sort = TRUE)

    p <- ggplot(
      segment_data,
      aes(
        x = reorder(Segment, n),
        y = n,
        text = paste0(Segment, ": ", scales::comma(n))
      )
    ) +
      geom_col(fill = "#8b5cf6") +
      coord_flip() +
      theme_minimal(base_size = 12) +
      theme(
        plot.background = element_rect(fill = "transparent", color = NA),
        panel.background = element_rect(fill = "transparent", color = NA),
        text = element_text(color = "white"),
        axis.text = element_text(color = "#a7afc2"),
        panel.grid = element_line(color = "white", alpha = 0.06)
      ) +
      labs(x = NULL, y = NULL)

    ggplotly(p, tooltip = "text") %>% config(displayModeBar = FALSE)
  })

  output$country_plot <- renderPlotly({
    country_data <- countries %>% slice_max(Revenue, n = 10, with_ties = FALSE)

    p <- ggplot(
      country_data,
      aes(
        x = reorder(Country, Revenue),
        y = Revenue,
        text = paste0(
          Country,
          "<br>Revenue: ", fmt_money(Revenue),
          "<br>Customers: ", scales::comma(Customers)
        )
      )
    ) +
      geom_col(fill = "#06b6d4") +
      coord_flip() +
      scale_y_continuous(labels = scales::label_currency(prefix = "£", big.mark = ",")) +
      theme_minimal(base_size = 11) +
      theme(
        plot.background = element_rect(fill = "transparent", color = NA),
        panel.background = element_rect(fill = "transparent", color = NA),
        text = element_text(color = "white"),
        axis.text = element_text(color = "#a7afc2"),
        panel.grid = element_line(color = "white", alpha = 0.06)
      ) +
      labs(x = NULL, y = NULL)

    ggplotly(p, tooltip = "text") %>% config(displayModeBar = FALSE)
  })

  output$cluster_plot <- renderPlotly({
    p <- ggplot(
      rfm,
      aes(
        x = Recency,
        y = Monetary,
        color = Cluster,
        text = paste0(
          "Customer: ", CustomerID,
          "<br>Recency: ", round(Recency), " days",
          "<br>Monetary: ", fmt_money(Monetary)
        )
      )
    ) +
      geom_point(alpha = 0.55, size = 1.7) +
      scale_y_continuous(labels = scales::label_currency(prefix = "£", big.mark = ",")) +
      theme_minimal(base_size = 11) +
      theme(
        plot.background = element_rect(fill = "transparent", color = NA),
        panel.background = element_rect(fill = "transparent", color = NA),
        text = element_text(color = "white"),
        axis.text = element_text(color = "#a7afc2"),
        panel.grid = element_line(color = "white", alpha = 0.06)
      ) +
      labs(x = "Recency (days)", y = "Monetary")

    ggplotly(p, tooltip = "text") %>% config(displayModeBar = FALSE)
  })

  # -----------------------------
  # Customer DNA
  # -----------------------------
  output$dna_ui <- renderUI({
    customer_choices <- sort(unique(rfm$CustomerID))

    div(
      class = "container-fluid",
      fluidRow(
        column(
          width = 4,
          div(
            class = "glass p-3",
            selectInput(
              "customer_id",
              "Select Customer",
              choices = customer_choices,
              selected = customer_choices[1]
            ),
            selectInput(
              "dna_metric",
              "DNA comparison",
              choices = c("RFM Scores", "Raw Values")
            )
          )
        ),
        column(
          width = 8,
          div(
            class = "glass p-4",
            uiOutput("dna_summary"),
            plotlyOutput("dna_radar", height = "430px")
          )
        )
      ),
      br(),
      fluidRow(
        column(
          width = 12,
          div(
            class = "glass p-3",
            div(class = "section-title", "Purchase History"),
            DTOutput("customer_history")
          )
        )
      )
    )
  })

  selected_customer <- reactive({
    req(input$customer_id)
    rfm %>% filter(CustomerID == input$customer_id) %>% slice(1)
  })

  output$dna_summary <- renderUI({
    x <- selected_customer()

    div(
      h3(paste0("Customer ", x$CustomerID)),
      span(class = "tag", x$Personality),
      br(),
      br(),
      fluidRow(
        column(
          width = 4,
          div(class = "metric-big", x$RFM_Score),
          div(class = "section-subtitle", "RFM Score")
        ),
        column(
          width = 4,
          div(class = "metric-big", x$Frequency),
          div(class = "section-subtitle", "Orders")
        ),
        column(
          width = 4,
          div(class = "metric-big", fmt_money(x$Monetary)),
          div(class = "section-subtitle", "Monetary Value")
        )
      )
    )
  })

  output$dna_radar <- renderPlotly({
    x <- selected_customer()

    if (input$dna_metric == "RFM Scores") {
      values <- c(x$R_Score, x$F_Score, x$M_Score)
    } else {
      values <- c(x$Recency, x$Frequency, log10(x$Monetary + 1))
    }

    labels <- c("Recency", "Frequency", "Monetary")
    values <- c(values, values[1])
    labels <- c(labels, labels[1])

    plot_ly(
      r = values,
      theta = labels,
      type = "scatterpolar",
      fill = "toself",
      line = list(color = "#8b5cf6"),
      fillcolor = "rgba(139,92,246,.22)"
    ) %>%
      layout(
        polar = list(radialaxis = list(visible = TRUE)),
        showlegend = FALSE,
        paper_bgcolor = "rgba(0,0,0,0)"
      )
  })

  output$customer_history <- renderDT({
    history <- customer_purchase_history(raw_data, input$customer_id)

    history %>%
      mutate(
        InvoiceDate = format(InvoiceDate, "%d %b %Y %H:%M"),
        OrderValue = fmt_money(OrderValue)
      ) %>%
      datatable(
        options = list(pageLength = 8, scrollX = TRUE),
        rownames = FALSE
      )
  })

  # -----------------------------
  # Retention Lab
  # -----------------------------
  output$retention_ui <- renderUI({
    retention_values <- cohort$Retention[cohort$MonthNumber > 0]
    retention_average <- round(mean(retention_values, na.rm = TRUE), 1)

    div(
      class = "container-fluid",
      fluidRow(
        column(
          width = 8,
          div(
            class = "glass p-3",
            div(class = "section-title", "Retention Heatmap"),
            div(class = "section-subtitle", "Percentage of cohort customers returning after first purchase"),
            plotlyOutput("cohort_heatmap", height = "500px")
          )
        ),
        column(
          width = 4,
          div(
            class = "glass p-4",
            div(class = "section-title", "Retention Snapshot"),
            div(class = "metric-big", paste0(retention_average, "%")),
            div(class = "section-subtitle", "Average observed retention after month 0"),
            hr(),
            p("Cohorts group customers by the month of their first purchase. Darker cells indicate stronger retention.")
          )
        )
      )
    )
  })

  output$cohort_heatmap <- renderPlotly({
    heatmap_data <- cohort %>%
      filter(MonthNumber <= 8) %>%
      mutate(Cohort = format(CohortMonth, "%b %Y"))

    plot_ly(
      heatmap_data,
      x = ~MonthNumber,
      y = ~Cohort,
      z = ~Retention,
      type = "heatmap",
      colorscale = "Viridis",
      hovertemplate = paste0(
        "Cohort: %{y}<br>",
        "Month: %{x}<br>",
        "Retention: %{z:.1f}%<extra></extra>"
      )
    ) %>%
      layout(
        xaxis = list(title = "Months after first purchase"),
        yaxis = list(title = "Cohort"),
        paper_bgcolor = "rgba(0,0,0,0)"
      )
  })

  # -----------------------------
  # Product Explorer
  # -----------------------------
  output$products_ui <- renderUI({
    div(
      class = "container-fluid",
      fluidRow(
        column(
          width = 8,
          div(
            class = "glass p-3",
            div(class = "section-title", "Top Products by Revenue"),
            plotlyOutput("product_plot", height = "480px")
          )
        ),
        column(
          width = 4,
          div(
            class = "glass p-3",
            div(class = "section-title", "Product Filters"),
            selectInput(
              "product_country",
              "Country",
              choices = c("All", sort(unique(raw_data$Country))),
              selected = "All"
            ),
            numericInput(
              "top_n",
              "Top products",
              value = 10,
              min = 5,
              max = 25,
              step = 1
            )
          )
        )
      ),
      br(),
      div(class = "glass p-3", DTOutput("product_table"))
    )
  })

  filtered_products <- reactive({
    product_data <- raw_data

    if (!is.null(input$product_country) && input$product_country != "All") {
      product_data <- product_data %>% filter(Country == input$product_country)
    }

    product_summary(product_data)
  })

  output$product_plot <- renderPlotly({
    plot_data <- filtered_products() %>%
      slice_max(Revenue, n = input$top_n, with_ties = FALSE)

    p <- ggplot(
      plot_data,
      aes(
        x = reorder(Product, Revenue),
        y = Revenue,
        text = paste0(
          Product,
          "<br>Revenue: ", fmt_money(Revenue),
          "<br>Units: ", scales::comma(Units)
        )
      )
    ) +
      geom_col(fill = "#8b5cf6") +
      coord_flip() +
      scale_y_continuous(labels = scales::label_currency(prefix = "£", big.mark = ",")) +
      theme_minimal() +
      theme(
        plot.background = element_rect(fill = "transparent", color = NA),
        panel.background = element_rect(fill = "transparent", color = NA),
        text = element_text(color = "white"),
        axis.text = element_text(color = "#a7afc2"),
        panel.grid = element_line(color = "white", alpha = 0.06)
      ) +
      labs(x = NULL, y = NULL)

    ggplotly(p, tooltip = "text") %>% config(displayModeBar = FALSE)
  })

  output$product_table <- renderDT({
    filtered_products() %>%
      slice_max(Revenue, n = 50, with_ties = FALSE) %>%
      mutate(Revenue = fmt_money(Revenue)) %>%
      datatable(
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE
      )
  })

  # -----------------------------
  # Smart Insights
  # -----------------------------
  output$insights_ui <- renderUI({
    insight_cards <- lapply(insights, function(item) {
      div(class = "insight", item)
    })

    div(
      class = "container-fluid",
      fluidRow(
        column(
          width = 8,
          div(
            class = "glass p-4",
            div(class = "section-title", "🧠 Smart Insights"),
            div(class = "section-subtitle", "Rule-based observations generated from the current dataset"),
            insight_cards
          )
        ),
        column(
          width = 4,
          div(
            class = "glass p-4",
            div(class = "section-title", "RFM Segment Guide"),
            p(strong("Champions"), " — recent, frequent and high-value customers."),
            p(strong("Loyal"), " — customers with strong repeat behaviour."),
            p(strong("Potential"), " — customers with room to increase engagement."),
            p(strong("At Risk"), " — customers showing weaker recent activity."),
            p(strong("Lost"), " — historically inactive customers.")
          )
        )
      )
    )
  })

  # -----------------------------
  # Campaign Simulator
  # -----------------------------
  output$campaign_ui <- renderUI({
    segment_choices <- sort(unique(rfm$Segment))
    default_segment <- if ("At Risk Customers" %in% segment_choices) {
      "At Risk Customers"
    } else {
      segment_choices[1]
    }

    div(
      class = "container-fluid",
      fluidRow(
        column(
          width = 5,
          div(
            class = "glass p-4",
            div(class = "section-title", "🎯 Campaign Simulator"),
            div(class = "section-subtitle", "A transparent what-if estimate, not a prediction."),
            selectInput(
              "campaign_segment",
              "Target segment",
              choices = segment_choices,
              selected = default_segment
            ),
            sliderInput(
              "discount",
              "Discount",
              min = 0,
              max = 30,
              value = 15,
              step = 1,
              post = "%"
            ),
            sliderInput(
              "response",
              "Expected response rate",
              min = 1,
              max = 60,
              value = 20,
              step = 1,
              post = "%"
            )
          )
        ),
        column(
          width = 7,
          div(
            class = "glass p-4",
            div(class = "section-title", "Simulation Result"),
            uiOutput("campaign_result")
          )
        )
      )
    )
  })

  output$campaign_result <- renderUI({
    req(input$campaign_segment, input$response, input$discount)

    segment_data <- rfm %>% filter(Segment == input$campaign_segment)
    targeted <- nrow(segment_data)
    responders <- round(targeted * input$response / 100)
    average_order_value <- if (targeted > 0) mean(segment_data$AverageOrderValue) else 0
    gross_revenue <- responders * average_order_value
    net_revenue <- gross_revenue * (1 - input$discount / 100)

    div(
      class = "sim-result",
      h2(paste0(scales::comma(targeted), " customers targeted")),
      fluidRow(
        column(
          width = 4,
          h4(scales::comma(responders)),
          p("Expected responders")
        ),
        column(
          width = 4,
          h4(fmt_money(gross_revenue)),
          p("Estimated gross revenue")
        ),
        column(
          width = 4,
          h4(fmt_money(net_revenue)),
          p("Estimated revenue after discount")
        )
      ),
      hr(),
      p(
        strong("Interpretation: "),
        "If the selected response rate occurs, the campaign could generate the displayed estimated revenue. Actual results may differ."
      ),
      downloadButton("download_campaign", "Download Simulation")
    )
  })

  output$download_campaign <- downloadHandler(
    filename = function() {
      paste0("campaign_simulation_", Sys.Date(), ".csv")
    },
    content = function(file) {
      segment_data <- rfm %>% filter(Segment == input$campaign_segment)
      result <- data.frame(
        Segment = input$campaign_segment,
        TargetedCustomers = nrow(segment_data),
        DiscountPercent = input$discount,
        ExpectedResponsePercent = input$response
      )
      write.csv(result, file, row.names = FALSE)
    }
  )

  # -----------------------------
  # Customer Data Explorer
  # -----------------------------
  output$data_ui <- renderUI({
    div(
      class = "container-fluid",
      div(
        class = "glass p-3",
        div(class = "section-title", "Customer Data Explorer"),
        div(class = "section-subtitle", "Search, sort and download customer-level analytics"),
        downloadButton("download_customers", "Download Customer CSV"),
        br(),
        br(),
        DTOutput("customer_table")
      )
    )
  })

  output$customer_table <- renderDT({
    rfm %>%
      select(
        CustomerID,
        Country,
        Recency,
        Frequency,
        Monetary,
        AverageOrderValue,
        RFM_Score,
        Segment,
        Personality,
        Cluster
      ) %>%
      mutate(
        across(c(Monetary, AverageOrderValue), ~ round(.x, 2))
      ) %>%
      datatable(
        filter = "top",
        options = list(pageLength = 15, scrollX = TRUE),
        rownames = FALSE
      )
  })

  output$download_customers <- downloadHandler(
    filename = "customer_intelligence_results.csv",
    content = function(file) {
      write.csv(rfm, file, row.names = FALSE)
    }
  )
}

ui <- page_fillable(
  theme = bs_theme(
    version = 5,
    bootswatch = "darkly",
    primary = "#8b5cf6",
    secondary = "#06b6d4",
    bg = "#090b12",
    fg = "#f5f7fb",
    base_font = font_google("Inter")
  ),
  tags$head(
    tags$style(HTML(
      "body{background:radial-gradient(circle at 15% 10%,#17152b 0,#090b12 38%,#07080d 100%)}
      .brand{font-size:1.35rem;font-weight:800}
      .subtitle{color:#a7afc2}
      .glass{background:rgba(18,21,33,.76);border:1px solid rgba(255,255,255,.08);border-radius:20px;box-shadow:0 12px 35px rgba(0,0,0,.25)}
      .kpi{padding:20px;min-height:125px}
      .kpi-label{color:#9da6bb;text-transform:uppercase;letter-spacing:1px;font-size:.72rem}
      .kpi-value{font-size:1.75rem;font-weight:800;margin-top:8px}
      .kpi-icon{float:right;font-size:1.6rem;color:#8b5cf6}
      .section-title{font-weight:800;margin-bottom:4px}
      .section-subtitle{color:#9da6bb;margin-bottom:15px}
      .nav-pills .nav-link.active{background:linear-gradient(135deg,#8b5cf6,#06b6d4)}
      .insight{padding:14px 16px;margin-bottom:10px;background:rgba(255,255,255,.035);border-radius:14px;border-left:3px solid #8b5cf6}
      .metric-big{font-size:2.4rem;font-weight:800}
      .tag{display:inline-block;padding:6px 10px;border-radius:999px;background:rgba(139,92,246,.16);color:#c4b5fd;font-weight:700}
      .sim-result{padding:18px;border-radius:16px;background:linear-gradient(135deg,rgba(139,92,246,.15),rgba(6,182,212,.10))}"
    ))
  ),
  div(
    class = "container-fluid p-4",
    div(
      class = "mb-4",
      div(class = "brand", "🛍 Customer Intelligence Studio"),
      div(class = "subtitle", "Understand • Segment • Discover • Act | Online Retail Analytics")
    ),
    navset_pill_list(
      id = "page",
      widths = c(2, 10),
      nav_panel("Overview", value = "overview", icon = bs_icon("grid-1x2"), uiOutput("overview_ui")),
      nav_panel("Customer DNA", value = "dna", icon = bs_icon("person-badge"), uiOutput("dna_ui")),
      nav_panel("Retention Lab", value = "retention", icon = bs_icon("arrow-repeat"), uiOutput("retention_ui")),
      nav_panel("Product Explorer", value = "products", icon = bs_icon("box-seam"), uiOutput("products_ui")),
      nav_panel("Smart Insights", value = "insights", icon = bs_icon("lightbulb"), uiOutput("insights_ui")),
      nav_panel("Campaign Simulator", value = "campaign", icon = bs_icon("bullseye"), uiOutput("campaign_ui")),
      nav_panel("Customer Data", value = "data", icon = bs_icon("table"), uiOutput("data_ui"))
    )
  )
)

shinyApp(ui = ui, server = server)
