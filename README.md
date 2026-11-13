# 🚀 Customer Intelligence Studio

### Interactive E-Commerce Customer Analytics & Segmentation Platform

[![R](https://img.shields.io/badge/R-Programming-276DC3?logo=r&logoColor=white)](https://www.r-project.org/)
[![Shiny](https://img.shields.io/badge/Shiny-Interactive%20Dashboard-0B7FAB?logo=r&logoColor=white)](https://shiny.posit.co/)
[![Plotly](https://img.shields.io/badge/Plotly-Interactive%20Charts-3F4F75?logo=plotly&logoColor=white)](https://plotly.com/r/)
[![GitHub](https://img.shields.io/badge/GitHub-Repository-181717?logo=github&logoColor=white)](https://github.com/SoumityaPandey/Customer-Intelligence-Studio)

> **Understand • Segment • Discover • Act**

Customer Intelligence Studio is an end-to-end **R + Shiny customer analytics platform** that transforms raw e-commerce transactions into actionable customer intelligence.

It combines **data cleaning, KPI analysis, RFM segmentation, customer personas, K-Means clustering, silhouette validation, cohort retention analysis, product analytics, geographic intelligence, rule-based insights, and campaign simulation** into one interactive application.

---

## 🌐 Live Demo

### 👉 [🚀 Launch Customer Intelligence Studio](https://connect.posit.cloud/soumityapandey/content/01a1d51a-24f0-90ff-cd5d-ab59d91c2680)

**No RStudio installation is required to explore the deployed application.**

The application is deployed using **Posit Connect Cloud**.

---

## 💡 Why This Project?

Many customer analytics projects stop at:

```text
CSV → Analysis → Charts
```

Customer Intelligence Studio goes further:

```text
Raw Transactions
       ↓
Data Cleaning
       ↓
Customer-Level Analytics
       ↓
RFM Segmentation
       ↓
K-Means Clustering
       ↓
Silhouette Validation
       ↓
Retention & Product Analytics
       ↓
Business Insights
       ↓
Campaign Simulation
       ↓
Interactive Shiny Application
       ↓
Cloud Deployment
```

The goal is to build not just an analysis script, but a **complete interactive analytics product**.

---

# 📊 Project at a Glance

| Metric | Result |
|---|---:|
| Raw Transactions | **541,909** |
| Clean Transactions | **397,884** |
| Customers | **4,338** |
| Orders | **18,532** |
| Revenue | **£8,911,408** |
| Average Order Value | **£481** |
| Repeat Customer Rate | **65.6%** |
| Countries | **37** |
| At Risk + Lost Customers | **1,309** |
| Optimal K | **2** |
| Silhouette Score | **0.433** |
| Observed Retention | **23.9%** |

---

# ✨ Key Features

### 📈 Executive Overview

A business-focused dashboard containing:

- Revenue
- Customers
- Orders
- Average Order Value
- Monthly revenue trends
- Customer segment distribution
- Country revenue intelligence
- K-Means cluster visualization

---

### 🧬 Customer DNA

Deep-dive into individual customers using:

- Recency
- Frequency
- Monetary value
- RFM Score
- Customer Segment
- Customer Personality
- Order history
- Interactive RFM radar visualization

Example customer personalities include:

```text
VIP Shopper
Big Spender
Loyal Shopper
Promising Shopper
Sleeping Giant
Dormant Shopper
```

---

### 🔄 Retention Lab

Cohort-based customer retention analysis with:

- First-purchase cohorts
- Month-by-month retention
- Interactive heatmap
- Retention snapshot
- Cohort comparison

Final dashboard result:

> **23.9% average observed retention after month 0**

---

### 📦 Product Explorer

Explore product performance by country.

Metrics include:

- Revenue
- Units sold
- Customers
- Orders

Users can select a country and dynamically change the number of top products displayed.

---

### 🌍 Country Intelligence

Analyze customer activity across different markets using:

- Revenue
- Customers
- Orders
- Units

The United Kingdom is the leading revenue market in the final analysis, contributing approximately **£7.31 million**.

---

### 🧠 Smart Insights

Automatically generates **rule-based observations** from the current dataset.

Examples:

- Leading revenue market
- Largest customer segment
- At Risk + Lost customer count
- Repeat customer percentage
- Retention-oriented recommendations

The insight engine is deliberately **rule-based and explainable**, rather than presenting generated statements as predictive AI.

---

### 🎯 Campaign Simulator

An interactive marketing **what-if simulator**.

Users select:

- Target customer segment
- Discount percentage
- Expected response rate

The application estimates:

```text
Targeted Customers
        ↓
Expected Responders
        ↓
Estimated Gross Revenue
        ↓
Estimated Revenue After Discount
```

> The simulator is a transparent scenario estimator, **not a predictive campaign-response model**.

---

### 📋 Customer Data Explorer

Interactive customer-level table supporting:

- Search
- Sorting
- Filtering
- Pagination
- CSV download

Customer-level fields include:

```text
CustomerID
Country
Recency
Frequency
Monetary
Average Order Value
RFM Score
Segment
Personality
Cluster
```

---

# 🧠 Analytical Methods

## RFM Analysis

Customer behaviour is represented using:

### Recency
How recently the customer purchased.

### Frequency
How frequently the customer placed orders.

### Monetary
How much the customer spent.

These values are scored and combined into an overall RFM Score.

### Customer Segments

| RFM Score | Segment |
|---:|---|
| ≥ 13 | 🏆 Champions |
| 10–12 | 💙 Loyal Customers |
| 7–9 | 🌱 Potential Customers |
| 5–6 | ⚠️ At Risk Customers |
| < 5 | 💤 Lost Customers |

---

# 🤖 K-Means Clustering

Customer behaviour is additionally analysed using K-Means clustering.

### Pipeline

```text
Recency
Frequency
Monetary
      ↓
Log Transformation
      ↓
Feature Scaling
      ↓
K-Means
      ↓
Silhouette Validation
```

Candidate values:

```text
K = 2
K = 3
K = 4
K = 5
K = 6
```

The application evaluates the average silhouette score for each candidate and automatically selects the best-performing K.

### Final Result

```text
Optimal K       = 2
Silhouette      = 0.433
```

This avoids choosing the cluster count arbitrarily.

---

# 🔄 Cohort Retention Analysis

Customers are grouped according to their **first purchase month**.

The system then tracks subsequent purchases across later months.

```text
First Purchase
      ↓
Cohort Assignment
      ↓
Month 1
      ↓
Month 2
      ↓
Month 3
      ↓
...
      ↓
Retention Heatmap
```

This helps identify cohorts with stronger or weaker repeat behaviour.

---

# 🧹 Data Preparation

The project starts with **541,909 raw transactions**.

The cleaning process removes:

- Missing Customer IDs
- Missing transaction dates
- Cancelled invoices
- Non-positive quantities
- Non-positive unit prices

Transaction value is calculated as:

```text
TotalAmount = Quantity × UnitPrice
```

After cleaning:

> **397,884 valid transactions**

remain for analysis.

---

# 🏗️ System Architecture

```text
                    ONLINE RETAIL DATA
                            │
                            ▼
                    Data Cleaning
                            │
                            ▼
                  Clean Transaction Data
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
          ▼                 ▼                 ▼
         KPI               RFM             Cohort
      Analysis           Analysis          Analysis
          │                 │                 │
          │                 ▼                 │
          │           Segmentation            │
          │                 │                 │
          │                 ▼                 │
          │          K-Means Clustering       │
          │                 │                 │
          └─────────────────┼─────────────────┘
                            ▼
                  Customer Intelligence
                            │
          ┌─────────────────┼─────────────────┐
          ▼                 ▼                 ▼
      Products          Countries         Insights
          │                 │                 │
          └─────────────────┼─────────────────┘
                            ▼
                    Shiny Dashboard
                            │
                            ▼
                    Posit Connect Cloud
                            │
                            ▼
                       LIVE WEB APP
```

---

# 🛠️ Technology Stack

### Programming & Application

- **R**
- **Shiny**
- **bslib**
- **bsicons**

### Data Processing

- **dplyr**
- **tidyr**
- **lubridate**

### Visualization

- **ggplot2**
- **Plotly**

### Interactive Tables

- **DT**

### Analytics & Machine Learning

- RFM Analysis
- K-Means Clustering
- Silhouette Analysis
- Cohort Analysis

### Development & Deployment

- RStudio
- Visual Studio Code
- Git
- GitHub
- Posit Connect Cloud

---

# 📁 Repository Structure

```text
Customer-Intelligence-Studio/
│
├── app/
│   └── app.R
│
├── R/
│   └── analysis.R
│
├── data/
│   ├── clean_retail_data.rds
│   └── README.md
│
├── tests/
│   └── testthat/
│       └── test-analysis.R
│
├── outputs/
│
├── packages.R
├── run_analysis.R
├── README.md
├── LICENSE
└── .gitignore
```

### Dataset Handling

The original `OnlineRetail.csv` is approximately **43.5 MB** and is intentionally excluded from GitHub.

The application uses the processed:

```text
data/clean_retail_data.rds
```

file instead.

This keeps the repository smaller and makes deployment more reliable.

---

# 🚀 Run Locally

## 1. Clone the repository

```bash
git clone https://github.com/SoumityaPandey/Customer-Intelligence-Studio.git
cd Customer-Intelligence-Studio
```

## 2. Open the project in RStudio

Install the required packages:

```r
source("packages.R")
```

## 3. Run the Shiny application

```r
shiny::runApp("app")
```

The dashboard will open in your browser.

---

# ☁️ Deployment

The application is deployed through **Posit Connect Cloud**.

### Deployment workflow

```text
R + Shiny
   ↓
Local Testing
   ↓
Data Preprocessing
   ↓
RDS Dataset
   ↓
Posit Connect Cloud
   ↓
HTTPS Web Application
```

### 🌐 Live Application

**[🚀 Open Customer Intelligence Studio](https://connect.posit.cloud/soumityapandey/content/01a1d51a-24f0-90ff-cd5d-ab59d91c2680)**

The live application was verified against the final local analytical results.

---

# 📈 Final Analytical Results

### Business Performance

```text
Revenue              £8,911,408
Customers                 4,338
Orders                    18,532
Average Order Value         £481
```

### Customer Behaviour

```text
Repeat Customer Rate       65.6%
At Risk + Lost Customers   1,309
```

### Machine Learning

```text
Optimal K                   2
Silhouette Score          0.433
```

### Retention

```text
Observed Retention        23.9%
```

---

# 🧪 Testing

The repository includes `testthat` tests for core analytical functions.

The tests validate key aspects such as:

- RFM output structure
- Required customer-level fields
- Positive Frequency values
- Positive Monetary values
- Core analytical calculations

---

# ⚠️ Limitations

- The dataset represents historical retail transactions rather than real-time transactions.
- RFM segmentation depends on the selected scoring methodology.
- K-Means results depend on feature transformation, scaling, initialization, and K selection.
- The Campaign Simulator is a