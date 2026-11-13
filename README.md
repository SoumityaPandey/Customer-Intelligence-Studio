# 🚀 Customer Intelligence Studio

### Interactive E-Commerce Customer Analytics & Segmentation Platform

> **Understand • Segment • Discover • Act**

Customer Intelligence Studio is an interactive **R + Shiny customer analytics platform** that transforms raw e-commerce transaction data into actionable customer intelligence.

The application combines **RFM analysis, customer segmentation, K-Means clustering, silhouette validation, cohort retention analysis, product analytics, geographic analysis, rule-based insights, and campaign simulation** inside a modern interactive dashboard.

### 🌐 Live Demo

**[🚀 Open Customer Intelligence Studio](https://connect.posit.cloud/soumityapandey/content/01a1d51a-24f0-90ff-cd5d-ab59d91c2680)**

> The application is deployed on **Posit Connect Cloud** and can be explored directly from a browser without installing R or RStudio.

---

## 📊 Project Snapshot

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

## 📈 1. Executive Overview

A business-oriented dashboard that provides an immediate view of:

- Total Revenue
- Total Customers
- Total Orders
- Average Order Value
- Monthly Revenue Pulse
- Customer Segment Distribution
- Country Revenue Intelligence
- K-Means Cluster Analysis

The Overview is designed to answer:

> **"What is happening in the customer base?"**

---

## 🧬 2. Customer DNA

A customer-level intelligence module for investigating individual customers.

For a selected customer, the application provides:

- RFM Score
- Recency
- Frequency
- Monetary Value
- Average Order Value
- Customer Segment
- Customer Personality
- Purchase History
- Interactive RFM Radar
- Customer-level transaction information

### Example customer personas

- 👑 VIP Shopper
- 💎 Big Spender
- 🔄 Loyal Shopper
- 🌱 Promising Shopper
- 😴 Sleeping Giant
- 💤 Dormant Shopper

This transforms aggregate analytics into **individual customer intelligence**.

---

# 🔄 3. Retention Lab

The Retention Lab performs **cohort-based retention analysis**.

It provides:

- First-purchase cohort identification
- Month-by-month retention
- Interactive retention heatmap
- Retention snapshot
- Cohort comparison

The final dashboard reports an average observed retention of:

> **23.9%**

The heatmap makes it easy to identify cohorts with stronger or weaker repeat behaviour.

---

# 📦 4. Product Explorer

An interactive product-performance module.

Users can:

- Select a country
- Choose the number of top products
- Compare product revenue
- Compare units sold
- View customer reach
- View order counts
- Search and sort products

### Product-level metrics

```text
Revenue
Units
Customers
Orders
```

This connects **product performance with geographic context**.

---

# 🧠 5. Smart Insights

Instead of forcing users to interpret every chart manually, the application generates **rule-based observations** from the dataset.

Examples include:

- Leading revenue market
- Largest customer segment
- At Risk + Lost customer count
- Repeat customer percentage
- Retention recommendations

These insights are deliberately **rule-based and explainable** rather than being presented as opaque AI-generated predictions.

---

# 🎯 6. Campaign Simulator

A transparent **what-if marketing simulator**.

Users can select:

- Target customer segment
- Discount percentage
- Expected response rate

The dashboard then estimates:

```text
Targeted Customers
        ↓
Expected Responders
        ↓
Estimated Gross Revenue
        ↓
Estimated Revenue After Discount
```

### Important

The simulator is explicitly a **scenario estimate, not a prediction**.

This makes the feature easy to explain academically and avoids presenting assumed response rates as a trained predictive model.

---

# 📋 7. Customer Data Explorer

A complete customer-level analytical table with:

- Customer ID
- Country
- Recency
- Frequency
- Monetary Value
- Average Order Value
- RFM Score
- Segment
- Personality
- Cluster

The table supports:

- Search
- Sorting
- Filtering
- Pagination
- CSV download

The final dataset contains:

> **4,338 customer records**

---

# 🤖 Analytical Methods

## RFM Analysis

Customer behaviour is summarized using three dimensions:

### Recency

How recently the customer purchased.

### Frequency

How frequently the customer places orders.

### Monetary

How much the customer spends.

These values are converted into scores and combined into an overall **RFM Score**.

### Customer Segments

| RFM Score | Segment |
|---:|---|
| ≥ 13 | 🏆 Champions |
| 10–12 | 💙 Loyal Customers |
| 7–9 | 🌱 Potential Customers |
| 5–6 | ⚠️ At Risk Customers |
| < 5 | 💤 Lost Customers |

---

# 🔬 K-Means Customer Clustering

The project uses **K-Means clustering** to discover behavioural groups beyond the manually defined RFM segments.

The clustering pipeline is:

```text
Recency
Frequency
Monetary
    ↓
Log Transformation
    ↓
Scaling
    ↓
K-Means
    ↓
Cluster Validation
```

Instead of arbitrarily selecting a cluster count, candidate values:

```text
K = 2
K = 3
K = 4
K = 5
K = 6
```

are evaluated using the **average silhouette score**.

### Final result

```text
Optimal K       = 2
Silhouette      = 0.433
```

This makes the clustering process more **data-driven and defensible**.

---

# 🔄 Cohort Retention Analysis

Customers are grouped according