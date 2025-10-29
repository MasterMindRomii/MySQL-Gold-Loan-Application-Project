# Gold Loan Application System - Database Design & More...
[![Database: MySQL](https://img.shields.io/badge/Database-MySQL%208.0-blue.svg)](https://www.mysql.com/)
[![Status: Production Ready](https://img.shields.io/badge/Status-Production%20Ready-success.svg)]()

> A comprehensive, enterprise-grade database schema for managing gold loan operations with complete workflow automation, multi-level approvals, and advanced analytics.

## Database Architecture

### Entity Relationship Model

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│  Customers  │────────▶│ Applications │────────▶│    Loans    │
└─────────────┘         └──────────────┘         └─────────────┘
       │                       │                        │
       │                       │                        │
       ▼                       ▼                        ▼
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│ Gold Assets │         │  Approvals   │         │  Payments   │
└─────────────┘         └──────────────┘         └─────────────┘
```

### Database Statistics
- **Tables**: 13 core + 3 views
- **Stored Procedures**: 2
- **Indexes**: 35+ optimized indexes

### Technology Stack
- **Database**: MySQL 8.0+ or PostgreSQL 13+
- **Normalization**: 3NF with strategic denormalization
- **Design Pattern**: Star schema for analytics

## Schema Details

### Core Tables

| Table | Description | Key Fields |
|-------|-------------|------------|
| `customers` | Customer master data | customer_id, pan_number, kyc_verified |
| `gold_assets` | Gold items catalog | asset_id, net_weight, purity_id, assessed_value |
| `loan_applications` | Application workflow | application_id, status, requested_amount |
| `loans` | Active loan accounts | loan_id, outstanding_principal, loan_status |
| `payments` | Payment transactions | payment_id, principal_paid, interest_paid |
| `employees` | Staff and officers | employee_id, role_id, branch_id |
| `branches` | Branch locations | branch_id, branch_code, branch_name |
| `loan_schemes` | Product configurations | scheme_id, interest_rate, loan_to_value_ratio |
| `loan_approvals` | Approval workflow | approval_id, approval_status, approver_id |
| `disbursements` | Loan payouts | disbursement_id, disbursement_mode |

### Business Logic Views

- `vw_customer_loan_summary` - Customer portfolio overview
- `vw_application_pipeline` - Pending applications dashboard  
- `vw_loan_performance` - Loan portfolio health metrics

### Stored Procedures

- `sp_calculate_eligible_loan()` - Calculate maximum loan eligibility based on collateral
- `sp_disburse_loan()` - Process loan disbursement with atomic transactions

## Sample Queries

### 1. Customer Portfolio Analysis
```sql
SELECT customer_name, active_loans, total_outstanding, total_collateral_value
FROM vw_customer_loan_summary
WHERE active_loans > 0
ORDER BY total_outstanding DESC
LIMIT 10;
```

### 2. Overdue Loans Report
```sql
SELECT 
    l.loan_account_number,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    l.outstanding_principal,
    DATEDIFF(CURRENT_DATE, l.maturity_date) as days_overdue
FROM loans l
JOIN customers c ON l.customer_id = c.customer_id
WHERE l.loan_status = 'OVERDUE'
ORDER BY days_overdue DESC;
```

### 3. Branch Performance Metrics
```sql
SELECT 
    b.branch_name,
    COUNT(l.loan_id) as total_loans,
    SUM(l.principal_amount) as total_disbursed,
    SUM(l.outstanding_principal) as total_outstanding,
    ROUND(AVG(l.interest_rate), 2) as avg_interest_rate
FROM branches b
LEFT JOIN loans l ON b.branch_id = l.branch_id
GROUP BY b.branch_id, b.branch_name;
```

### 4. Gold Inventory Status
```sql
SELECT 
    gps.purity_level,
    COUNT(*) as item_count,
    SUM(ga.net_weight) as total_weight_grams,
    SUM(ga.assessed_value) as total_value
FROM gold_assets ga
JOIN gold_purity_standards gps ON ga.purity_id = gps.purity_id
WHERE ga.status = 'PLEDGED'
GROUP BY gps.purity_level;
```

## Author

**Romi Gupta**
- GitHub: [@MasterMindRomii](https://github.com/MasterMindRomii)
- Project: [MySQL Gold Loan Application](https://github.com/MasterMindRomii/MySQL-Gold-Loan-Application-Project)


**Note**: This is an assignment project designed for the NATFLOW assessment. For production deployment, ensure proper security hardening, compliance reviews, and load testing.

**Created by Romi Gupta**
