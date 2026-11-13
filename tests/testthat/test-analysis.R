source("R/analysis.R")
test_that("RFM output contains required fields", {
  skip_if_not(file.exists("data/OnlineRetail.csv"))
  d <- clean_retail_data("data/OnlineRetail.csv")
  r <- create_rfm(d)
  expect_true(all(c("Recency","Frequency","Monetary","RFM_Score","Segment") %in% names(r)))
  expect_true(all(r$Frequency >= 1))
  expect_true(all(r$Monetary > 0))
})
