# Customer Shopping Behavior Analysis

**AI-Powered Data Analytics Internship | Brand Monk Academy**

**Project by:** Nithyasri A  
**Internship Mentors:** Ms. Harshini and Ms. Swetha  
**Reporting Period:** October 2026

## 1. Project Overview

Customer Shopping Behavior Analysis is an end-to-end data analytics project completed as part of my four-week AI-Powered Data Analytics Internship at Brand Monk Academy.

The project explores customer shopping transactions to identify sales patterns, product category performance, payment preferences, customer demographics, shopping mall performance, and time-based trends.

I used Microsoft Excel, MySQL, Python, and Power BI to organize the data, answer business questions, perform exploratory data analysis, and present business findings and recommendations.

## 2. Project Objectives

- Understand and inspect the customer shopping dataset.
- Validate data quality and prepare data for analysis.
- Calculate key performance indicators (KPIs).
- Use SQL to answer business questions.
- Perform exploratory data analysis (EDA) using Python.
- Create visual summaries and a Power BI report.
- Identify business patterns and provide data-driven recommendations.
- Document the project and organize the portfolio on GitHub.

## 3. Dataset Overview

| Attribute | Description |
|---|---|
| Dataset | Customer Shopping Dataset |
| Total records | 99,457 |
| Unique invoices | 99,457 |
| Unique customer IDs | 99,457 |
| Date range | January 1, 2021 – March 8, 2023 |
| Source fields | 15, including `index_no` |
| Analytical tools | Excel, MySQL, Python, Power BI |

The dataset includes transaction identifiers, customer demographics, product categories, quantity, recorded transaction value, payment methods, invoice dates, shopping malls, and regions.

### Important Data Interpretation

- `SUM(price)` is used to calculate total recorded sales.
- `SUM(quantity)` is used to calculate total quantity sold.
- `AVG(price)` represents the average recorded transaction value.
- **Price is not multiplied by quantity.**
- The source currency is not explicitly confirmed in the dataset metadata.

## 4. Tools and Technologies

| Tool | Purpose |
|---|---|
| Microsoft Excel | Data inspection, PivotTables, KPI summaries, and dashboard-style reporting |
| MySQL Workbench | Data validation, aggregations, business questions, subqueries, CTEs, window functions, and joins |
| Python | Data preparation, validation, exploratory analysis, and business insights |
| Pandas | Data manipulation, grouping, and summary analysis |
| NumPy | Rule-based data operations |
| Matplotlib and Seaborn | Data visualization |
| Power BI | KPI cards, charts, report pages, and business intelligence reporting |
| GitHub | Project documentation and portfolio organization |

## 5. Project Workflow

### Week 1 — Excel and SQL Analysis
- Inspected the dataset and identified business questions.
- Worked with Excel summaries, PivotTables, KPIs, and dashboard-style reporting.
- Prepared SQL queries for validation, aggregation, and business analysis.

### Week 2 — Python Exploratory Data Analysis
- Used Pandas and NumPy to inspect and analyse the data.
- Performed missing-value, duplicate, data-type, and range checks.
- Created summary tables and visualizations to explore category, gender, mall, payment, age, weekday, and monthly patterns.
- Reviewed potential outliers for further validation.

### Week 3 — Power BI Reporting
- Prepared a Power BI report package containing four pages: Dashboard, Analysis & Recommendations, Business Analysis, and Conclusion.
- Organized KPI cards, charts, slicers, and explanatory text to communicate findings.
- Further validation of DAX calculations, visual rendering, and interactive slicers remains a verification opportunity.

### Week 4 — GitHub Portfolio and SQL Review
- Created and organized the GitHub project repository.
- Reviewed SQL business questions, queries, documented outputs, and findings.
- Checked that interpretations followed the project's metric definitions.
- Organized the project deliverables for portfolio presentation.

## 6. Key Business Findings

### Overall KPIs

| Metric | Result |
|---|---:|
| Total recorded sales | 68,551,365.91 |
| Total quantity sold | 298,712 |
| Average recorded transaction value | 689.26 |
| Total transactions | 99,457 |

*Note: The source currency is not explicitly confirmed.*

### Main Findings

1. **Top product category:** Clothing recorded the highest total sales of 31,075,684.64 and the highest quantity sold of 103,558 units.
2. **Top shopping mall:** Mall of Istanbul recorded the highest mall-level sales of 13,851,737.62.
3. **Leading payment method:** Cash recorded the highest payment-method sales total of 30,705,030.98.
4. **Gender comparison:** Female transactions contributed total recorded sales of 40,931,801.62, compared with 27,619,564.29 for male transactions.
5. **Average transaction value:** Technology had the highest average recorded transaction value among categories, at 3,156.94.
6. **Weekday pattern:** Monday recorded the highest weekday sales total in the analysis. Monthly sales fluctuated during the available period.

These findings describe patterns in the supplied dataset and do not establish causal relationships or profitability.

## 7. Business Recommendations

- Monitor clothing demand, inventory availability, and seasonal sales patterns.
- Investigate the category mix and sales performance of Mall of Istanbul.
- Review payment-method patterns to support payment operations and customer convenience.
- Explore technology category transaction values alongside product margins, inventory, and demand.
- Review lower-sales categories such as Books and Souvenir before making assortment or pricing decisions.
- Compare equivalent time periods and account for the incomplete March 2023 data.
- Validate unusually high recorded transaction values before treating them as errors.

## 8. Project Files

The repository contains the project deliverables used to document the analysis:

- **Excel workbook:** Dataset analysis, KPI summaries, PivotTables, and dashboard-style reporting.
- **SQL script:** Data validation and business-question queries.
- **Python notebook:** Data checks, exploratory analysis, summaries, and visualizations.
- **Power BI report:** Dashboard and business analysis report.
- **Internship report:** Project methodology, findings, recommendations, progress, and limitations.

## 9. Data Quality and Limitations

- The dataset contains 99,457 records, with 99,457 distinct invoice numbers and customer IDs.
- Each customer ID appears once, so repeat-purchase frequency, retention, and customer lifetime value cannot be reliably measured from this dataset.
- March 2023 contains data only through March 8 and is an incomplete month.
- Age-group definitions differ between the source data and the Python-created age bands; standardization would improve consistency.
- Potential outliers identified through the IQR method require investigation and should not automatically be treated as errors.
- SQL query execution against a live MySQL database was not independently verified during the report review.
- Power BI visuals, DAX measures, relationships, and slicer interactions should be tested in Power BI Desktop.
- The source currency should be confirmed before presenting amounts with a currency symbol.

## 10. Future Improvements

- Standardize age groups, date handling, and metric definitions across tools.
- Validate SQL queries and save execution evidence.
- Test Power BI measures, relationships, and interactive filters.
- Add product margin, discounts, returns, inventory, or store traffic data for deeper business analysis.
- Use a dataset containing multiple transactions per customer for repeat-purchase and retention analysis.
- Document AI-assisted work and independently validate generated suggestions.

## 11. Skills Demonstrated

**Technical Skills:** Excel, MySQL, SQL, Python, Pandas, NumPy, Matplotlib, Seaborn, Power BI, and data visualization.

**Analytical Skills:** Data validation, KPI calculation, exploratory data analysis, business-question analysis, trend comparison, interpretation of findings, and business recommendations.

**Professional Skills:** Project documentation, structured problem-solving, analytical communication, and portfolio development.

## 12. Conclusion

This project gave me practical experience with the data analytics workflow, from understanding and validating a dataset to analysing business questions, creating visualizations, preparing a Power BI report, and documenting findings.

The project highlighted the importance of correct metric definitions, data-quality checks, consistent segmentation, and careful interpretation of results. It also helped me understand how Excel, SQL, Python, and Power BI can work together to support data-driven business decisions.

**Author:** Nithyasri A  
**Organization:** Brand Monk Academy  
**Project:** Customer Shopping Behavior Analysis
