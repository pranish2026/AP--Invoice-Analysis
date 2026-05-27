-- ============================================================
--  PROJECT: AP Invoice Analysis
--  Author : Mana Dangol Tamang
--  Tool   : MySQL
--  Purpose: Detect duplicate payments, analyze invoice aging,
--           and summarize vendor spend using simulated AP data
-- ============================================================


-- ------------------------------------------------------------
-- STEP 1: Create Database & Table
-- ------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS ap_analysis;
USE ap_analysis;

DROP TABLE IF EXISTS invoices;

CREATE TABLE invoices (
    invoice_id      INT PRIMARY KEY,
    vendor_name     VARCHAR(100),
    invoice_number  VARCHAR(50),
    invoice_date    DATE,
    due_date        DATE,
    amount          DECIMAL(10,2),
    status          VARCHAR(20)   -- 'Paid', 'Pending', 'Overdue'
);


-- ------------------------------------------------------------
-- STEP 2: Insert Sample Data
-- Note: Rows (1,2), (4,5), and (8,10) are intentional
--       duplicates simulating real AP data entry errors
-- ------------------------------------------------------------

INSERT INTO invoices VALUES
(1,  'ABC Supplies',    'INV-1001', '2024-01-05', '2024-02-04', 1500.00, 'Paid'),
(2,  'ABC Supplies',    'INV-1001', '2024-01-05', '2024-02-04', 1500.00, 'Paid'),
(3,  'XYZ Logistics',  'INV-2045', '2024-01-10', '2024-02-09', 3200.00, 'Overdue'),
(4,  'Delta Corp',     'INV-3012', '2024-01-15', '2024-02-14',  750.00, 'Pending'),
(5,  'Delta Corp',     'INV-3012', '2024-01-15', '2024-02-14',  750.00, 'Pending'),
(6,  'Alpha Tech',     'INV-4023', '2024-01-20', '2024-02-19', 4800.00, 'Paid'),
(7,  'XYZ Logistics',  'INV-2078', '2024-02-01', '2024-03-02', 2100.00, 'Pending'),
(8,  'Beta Services',  'INV-5001', '2024-02-05', '2024-03-06',  900.00, 'Overdue'),
(9,  'Alpha Tech',     'INV-4056', '2024-02-10', '2024-03-11', 3300.00, 'Pending'),
(10, 'Beta Services',  'INV-5001', '2024-02-05', '2024-03-06',  900.00, 'Overdue');


-- ------------------------------------------------------------
-- QUERY 1: Detect Duplicate Invoices
-- Finds same vendor + invoice number + amount appearing more
-- than once — flagging potential duplicate payment risk
-- ------------------------------------------------------------

SELECT
    vendor_name,
    invoice_number,
    amount,
    COUNT(*)        AS duplicate_count
FROM invoices
GROUP BY
    vendor_name,
    invoice_number,
    amount
HAVING COUNT(*) > 1
ORDER BY amount DESC;

/*
Expected Result:
vendor_name   | invoice_number | amount  | duplicate_count
ABC Supplies  | INV-1001       | 1500.00 | 2
Beta Services | INV-5001       |  900.00 | 2
Delta Corp    | INV-3012       |  750.00 | 2
*/


-- ------------------------------------------------------------
-- QUERY 2: Invoice Aging Analysis
-- Buckets all unpaid invoices by how overdue they are —
-- the same aging report used in weekly AP team reviews
-- ------------------------------------------------------------

SELECT
    invoice_id,
    vendor_name,
    invoice_number,
    amount,
    due_date,
    status,
    DATEDIFF(CURDATE(), due_date)   AS days_overdue,
    CASE
        WHEN DATEDIFF(CURDATE(), due_date) <= 0  THEN 'Current'
        WHEN DATEDIFF(CURDATE(), due_date) <= 30 THEN '1-30 Days Overdue'
        WHEN DATEDIFF(CURDATE(), due_date) <= 60 THEN '31-60 Days Overdue'
        ELSE '60+ Days Overdue'
    END                             AS aging_bucket
FROM invoices
WHERE status != 'Paid'
ORDER BY days_overdue DESC;

/*
Expected Result (buckets will vary based on current date):
Invoices sorted from most overdue to current,
grouped into aging buckets for AP team prioritization
*/


-- ------------------------------------------------------------
-- QUERY 3: Vendor Spend Summary
-- Ranks all vendors by total spend and invoice volume —
-- useful for identifying high-spend vendors and
-- consolidation or discount negotiation opportunities
-- ------------------------------------------------------------

SELECT
    vendor_name,
    COUNT(invoice_id)       AS total_invoices,
    SUM(amount)             AS total_spend,
    AVG(amount)             AS avg_invoice_amount
FROM invoices
GROUP BY vendor_name
ORDER BY total_spend DESC;

/*
Expected Result:
vendor_name   | total_invoices | total_spend | avg_invoice_amount
Alpha Tech    | 2              | 8100.00     | 4050.00
XYZ Logistics | 2              | 5300.00     | 2650.00
ABC Supplies  | 2              | 3000.00     | 1500.00
Beta Services | 2              | 1800.00     |  900.00
Delta Corp    | 2              | 1500.00     |  750.00
*/


-- ============================================================
-- END OF PROJECT
-- ============================================================
