
# Telco Customer Churn Analysis & Business Intelligence Dashboard

A complete end-to-end data analysis project that answers real business questions for a telecommunications company using the Telco Customer Churn dataset.

## About Dataset:
- Source: [Kaggle - Telco Customer Churn](https://www.kaggle.com/datasets/blastchar/telco-customer-churn) 

## Goal:
Identify who is leaving, why they are leaving, how much revenue is at risk, and deliver actionable recommendations to reduce churn and protect revenue.

## Key Findings & Actionable Recommendations

| Insight             |Recommendations|
| ----------------- | ------------------------------------------------------------------ |
| Who is most likely to churn and what can we do to retain them? | High risk segments identified (Fiber Optic + Month-to-month + < <12 months tenure + $70–$110 bill) |
| How much revenue are we losing due to churn?| $1.67M annual recurring revenue lost  full breakdown by segment |
| Why are Fiber Optic customers churning at higher rates? | Poor TechSupport experience is the #1 driver|
| Are certain payment methods linked to higher churn? | Electronic check 45% churn rate vs. Bank transfer/CC auto-pay < 18% |
| Who are our most loyal customers? | Two-year contract + TechSupport + tenure >24 months → 97%+ retention |





## Key Findings & Actionable Recommendations

| Insight             |Recommendations|
| ----------------- | ------------------------------------------------------------------ |
| Fiber Optic + Month-to-month + <12 months tenure + $70–$110 bill is the single deadliest segment | Offer locked 12-month contract at 15–20% discount for new/high-bill Fiber customers |
| 72% of all Fiber Optic customers do not have TechSupport This group has a 49% churn rate | Bundle TechSupport free for the first 12 months with every new Fiber contract |
| Electronic Check payment → 45% churn rate | Encourage Electronic Check customers to switch to Auto-Pay or credit card by using discounts or bonuses. |
| Customers with tenure >24 months and Two-Year contract >97% retention | Target this loyal “Prime” segment for safe upsell & cross-sell |
| Senior citizens (60+) churn at 41.7%  almost double the overall churn rate (26.5%) and the highest of any demographic group (MySQL EDA)| Simplified billing, Bundle TechSupport and Device Protection for first 12 months |


## Interactive Dashboards (Tableau Public)
link: [Tableau Public](https://public.tableau.com/app/profile/nick.starosta/viz/telco_dashboard/ChurnDashboard)

### Screenshots

## Tools & Technologies

- MySQL - Data Cleaning & Preparation, Exploratory Data Analysis
- Tableau - Visualization, Distribution, Storytelling calculated fields, LOD expressions, parameters, dynamic sets, table calculations

## Project Structure

```
  Telco-Churn-Analysis/
│
├── data/
│   └── WA_Fn-UseC_-Telco-Customer-Churn.csv          # Original dataset
│
├── sql/
│   └── TEL.sql              # Full script (included below)
│
├── data/
│   └── telco_fixed.csv                    # After Cleaning in MySQL
│
├── tableau/
│   └── Telco_Churn_Dashboard.twbx                    # Tableau workbook
│
├── images/
│   ├── churn_dashboard.png
│   └── revenue_dashboard.png
│
└── README.md                                         # You're reading it!
```

## 🔗 Links
[![github](https://img.shields.io/badge/GitHub-%23121011.svg?logo=github&logoColor=white)](https://github.com/nick-s-data)

[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/nick-starosta-93a512391/)


