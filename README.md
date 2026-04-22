
# New York City Airbnb Performance & Revenue Analysis

## Database and Source
**FinalProjectDB** (https://mavenanalytics.io/data-playground/airbnb-listings-reviews) 
*Original Data Source:* Inside Airbnb New York City Dataset 

## Overview
This project presents a performance and revenue analysis of Airbnb listings across the five boroughs of New York City using T-SQL. The objective is to evaluate property performance, guest satisfaction trends, and demographic spending patterns to optimize profitability for property hosts and urban management companies.

---

## Brief Description
This analysis utilizes a normalized relational database consisting of 7 tables (Hosts, Location, Properties, Listings, Tenants, Bookings, and Reviews). While the core listing and review data is derived from real-world New York City Airbnb records, we synthesized a "Tenants" and "Bookings" layer to simulate a complete transaction history. This allows for a deep-dive audit into how different traveler types (Business vs. Family) and neighborhood dynamics—from Manhattan to the outer boroughs—impact the overall financial health and reputation of the NYC hospitality ecosystem.

---

## Objectives
- **Identify Revenue Drivers:** Determine which NYC neighborhoods and property types generate the highest total revenue.
- **Analyze Guest Demographics:** Evaluate spending habits and stay durations based on age and trip purpose.
- **Quality Control:** Use multidimensional review scores (Cleanliness, Value, Communication) to find top-performing districts.
- **Host Performance:** Measure the impact of "Superhost" status and "Instant Booking" on occupancy rates and ratings.
- **Data-Driven Insights:** Support strategic decisions for property owners looking to invest in the competitive New York short-term rental market.

---

## Tools & Technologies
- **Azure SQL Database** (Cloud Hosting)
- **T-SQL** (Data Wrangling & Analysis)
- **Visual Studio Code** (Development Environment)
- **DBCode Extension** (Visualizations)
- **GitHub** (Version Control & Project Evolution)

---

## Key Analysis & Queries
The project includes 12 comprehensive analytical queries covering:

- **Borough & Neighborhood Revenue Ranking:** Identifying the top 5 income-generating areas in NYC.
- **Tenant Spending Patterns:** Analysis of revenue by age group and city of origin.
- **Superhost Pricing Premium:** Average price comparison between host tiers.
- **Cleanliness & Value Audits:** Aggregated review scores across New York's diverse neighborhoods.
- **Peak Season Discovery:** Time-series analysis of monthly check-in volumes.
- **Trip Purpose Analysis:** Comparing stay lengths for business travelers vs. solo tourists.
- **Price vs. Quality Detection:** Identifying overpriced properties with poor feedback scores.

**Full SQL script available here:** `https://github.com/Edcaly/Airbnb-Analytics-/edit/main/final_project_code.sql`
