# AP Invoice Analysis — SQL Project

## Overview
SQL project built to simulate real accounts payable data analysis.
Covers duplicate payment detection, invoice aging, and vendor spend
analysis — modeled on real AP workflows.

## Tool
MySQL

## Dataset
10 simulated AP invoice records based on real AP data structures

## Queries

### 1. Duplicate Invoice Detection
Identifies invoices with the same vendor, invoice number and amount
appearing more than once — flags potential double payment risk.

### 2. Invoice Aging Analysis
Buckets unpaid invoices into 0-30, 31-60, and 60+ day categories
using DATEDIFF and CASE statements.

### 3. Vendor Spend Summary
Ranks vendors by total spend using SUM, AVG, and COUNT to identify
high-spend accounts and consolidation opportunities.

## Skills Demonstrated
- SQL: GROUP BY, HAVING, COUNT, SUM, AVG, DATEDIFF, CASE WHEN
- AP Domain Knowledge: Duplicate detection, aging analysis, vendor spend
