-- GOLD LOAN APPLICATION - DATABASE SCHEMA

-- Database Creation
CREATE DATABASE IF NOT EXISTS gold_loan_management;
USE gold_loan_management;

-- 1. BRANCH MANAGEMENT

CREATE TABLE branches (
    branch_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_code VARCHAR(20) UNIQUE NOT NULL,
    branch_name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(50),
    pincode VARCHAR(10),
    phone VARCHAR(15),
    email VARCHAR(100),
    manager_name VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_branch_code (branch_code),
    INDEX idx_city (city)
);

-- 2. USER/EMPLOYEE MANAGEMENT

CREATE TABLE roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO roles (role_name, description) VALUES
('BRANCH_OFFICER', 'Processes loan applications'),
('BRANCH_MANAGER', 'First level approval'),
('REGIONAL_MANAGER', 'Second level approval'),
('ADMIN', 'System administrator'),
('AUDITOR', 'Audit and compliance');

CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_code VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    role_id INT NOT NULL,
    branch_id INT,
    manager_id INT,
    date_of_joining DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(role_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id),
    INDEX idx_employee_code (employee_code),
    INDEX idx_email (email),
    INDEX idx_role_branch (role_id, branch_id)
);

-- 3. CUSTOMER MANAGEMENT

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_code VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    gender ENUM('MALE', 'FEMALE', 'OTHER'),
    email VARCHAR(100),
    phone VARCHAR(15) NOT NULL,
    alternate_phone VARCHAR(15),
    pan_number VARCHAR(10) UNIQUE,
    aadhar_number VARCHAR(12) UNIQUE,
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    occupation VARCHAR(100),
    annual_income DECIMAL(15,2),
    credit_score INT,
    kyc_verified BOOLEAN DEFAULT FALSE,
    is_blacklisted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_customer_code (customer_code),
    INDEX idx_phone (phone),
    INDEX idx_pan (pan_number),
    INDEX idx_aadhar (aadhar_number),
    INDEX idx_kyc_status (kyc_verified, is_blacklisted)
);

-- 4. GOLD ASSET MANAGEMENT

CREATE TABLE gold_purity_standards (
    purity_id INT PRIMARY KEY AUTO_INCREMENT,
    purity_level VARCHAR(10) UNIQUE NOT NULL, -- 24K, 22K, 18K, etc.
    purity_percentage DECIMAL(5,2) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO gold_purity_standards (purity_level, purity_percentage, description) VALUES
('24K', 99.99, 'Pure Gold'),
('22K', 91.67, 'Most common for jewelry'),
('18K', 75.00, 'Standard gold alloy'),
('14K', 58.33, 'Affordable gold option');

CREATE TABLE gold_rate_history (
    rate_id INT PRIMARY KEY AUTO_INCREMENT,
    purity_id INT NOT NULL,
    rate_per_gram DECIMAL(10,2) NOT NULL,
    effective_date DATE NOT NULL,
    branch_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (purity_id) REFERENCES gold_purity_standards(purity_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
    INDEX idx_effective_date (effective_date),
    INDEX idx_purity_date (purity_id, effective_date)
);

CREATE TABLE gold_assets (
    asset_id INT PRIMARY KEY AUTO_INCREMENT,
    asset_code VARCHAR(20) UNIQUE NOT NULL,
    customer_id INT NOT NULL,
    item_type VARCHAR(50) NOT NULL, -- Necklace, Ring, Bangle, Coin, etc.
    item_description TEXT,
    gross_weight DECIMAL(10,3) NOT NULL, -- in grams
    net_weight DECIMAL(10,3) NOT NULL, -- after deducting stones
    purity_id INT NOT NULL,
    assessed_value DECIMAL(15,2) NOT NULL,
    market_value DECIMAL(15,2) NOT NULL,
    valuation_date DATE NOT NULL,
    valued_by_employee_id INT NOT NULL,
    storage_location VARCHAR(100),
    photo_url VARCHAR(500),
    status ENUM('AVAILABLE', 'PLEDGED', 'RELEASED', 'AUCTIONED') DEFAULT 'AVAILABLE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (purity_id) REFERENCES gold_purity_standards(purity_id),
    FOREIGN KEY (valued_by_employee_id) REFERENCES employees(employee_id),
    INDEX idx_customer (customer_id),
    INDEX idx_status (status),
    INDEX idx_asset_code (asset_code)
);

-- 5. LOAN APPLICATION MANAGEMENT

CREATE TABLE loan_schemes (
    scheme_id INT PRIMARY KEY AUTO_INCREMENT,
    scheme_name VARCHAR(100) UNIQUE NOT NULL,
    min_loan_amount DECIMAL(15,2) NOT NULL,
    max_loan_amount DECIMAL(15,2) NOT NULL,
    loan_to_value_ratio DECIMAL(5,2) NOT NULL, -- LTV % (e.g., 75.00 for 75%)
    interest_rate DECIMAL(5,2) NOT NULL,
    min_tenure_months INT NOT NULL,
    max_tenure_months INT NOT NULL,
    processing_fee_percentage DECIMAL(5,2),
    prepayment_allowed BOOLEAN DEFAULT TRUE,
    prepayment_penalty_percentage DECIMAL(5,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_scheme_active (is_active)
);

CREATE TABLE loan_applications (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    application_number VARCHAR(30) UNIQUE NOT NULL,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    scheme_id INT NOT NULL,
    officer_id INT NOT NULL,
    requested_amount DECIMAL(15,2) NOT NULL,
    tenure_months INT NOT NULL,
    purpose VARCHAR(255),
    collateral_value DECIMAL(15,2) NOT NULL,
    eligible_loan_amount DECIMAL(15,2),
    approved_amount DECIMAL(15,2),
    interest_rate DECIMAL(5,2),
    processing_fee DECIMAL(15,2),
    status ENUM('DRAFT', 'SUBMITTED', 'UNDER_REVIEW', 'PENDING_APPROVAL', 
                'APPROVED', 'REJECTED', 'DISBURSED', 'CANCELLED') DEFAULT 'DRAFT',
    application_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    submission_date TIMESTAMP NULL,
    rejection_reason TEXT,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
    FOREIGN KEY (scheme_id) REFERENCES loan_schemes(scheme_id),
    FOREIGN KEY (officer_id) REFERENCES employees(employee_id),
    INDEX idx_application_number (application_number),
    INDEX idx_customer (customer_id),
    INDEX idx_status (status),
    INDEX idx_application_date (application_date),
    INDEX idx_officer (officer_id)
);

CREATE TABLE application_assets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    asset_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (application_id) REFERENCES loan_applications(application_id) ON DELETE CASCADE,
    FOREIGN KEY (asset_id) REFERENCES gold_assets(asset_id),
    UNIQUE KEY unique_app_asset (application_id, asset_id),
    INDEX idx_application (application_id)
);

-- 6. APPROVAL WORKFLOW

CREATE TABLE approval_levels (
    level_id INT PRIMARY KEY AUTO_INCREMENT,
    level_number INT UNIQUE NOT NULL,
    level_name VARCHAR(50) NOT NULL,
    required_role_id INT NOT NULL,
    min_amount DECIMAL(15,2) DEFAULT 0,
    max_amount DECIMAL(15,2),
    description VARCHAR(255),
    FOREIGN KEY (required_role_id) REFERENCES roles(role_id),
    INDEX idx_level_number (level_number)
);

INSERT INTO approval_levels (level_number, level_name, required_role_id, min_amount, max_amount, description) VALUES
(1, 'Branch Manager Approval', 2, 0, 500000, 'First level approval by branch manager'),
(2, 'Regional Manager Approval', 3, 500001, NULL, 'Second level approval for high-value loans');

CREATE TABLE loan_approvals (
    approval_id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    level_id INT NOT NULL,
    approver_id INT NOT NULL,
    approval_status ENUM('PENDING', 'APPROVED', 'REJECTED', 'RETURNED') DEFAULT 'PENDING',
    approved_amount DECIMAL(15,2),
    comments TEXT,
    approved_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (application_id) REFERENCES loan_applications(application_id),
    FOREIGN KEY (level_id) REFERENCES approval_levels(level_id),
    FOREIGN KEY (approver_id) REFERENCES employees(employee_id),
    INDEX idx_application (application_id),
    INDEX idx_approver (approver_id),
    INDEX idx_status (approval_status)
);

-- 7. LOAN DISBURSEMENT & ACCOUNTS

CREATE TABLE loans (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    loan_account_number VARCHAR(30) UNIQUE NOT NULL,
    application_id INT NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    principal_amount DECIMAL(15,2) NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL,
    tenure_months INT NOT NULL,
    emi_amount DECIMAL(15,2) NOT NULL,
    total_payable DECIMAL(15,2) NOT NULL,
    disbursement_date DATE NOT NULL,
    maturity_date DATE NOT NULL,
    outstanding_principal DECIMAL(15,2) NOT NULL,
    outstanding_interest DECIMAL(15,2) DEFAULT 0,
    penalty_amount DECIMAL(15,2) DEFAULT 0,
    loan_status ENUM('ACTIVE', 'CLOSED', 'OVERDUE', 'NPA', 'FORECLOSED') DEFAULT 'ACTIVE',
    closure_date DATE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (application_id) REFERENCES loan_applications(application_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
    INDEX idx_loan_account (loan_account_number),
    INDEX idx_customer (customer_id),
    INDEX idx_status (loan_status),
    INDEX idx_disbursement_date (disbursement_date)
);

CREATE TABLE disbursements (
    disbursement_id INT PRIMARY KEY AUTO_INCREMENT,
    loan_id INT NOT NULL,
    disbursement_amount DECIMAL(15,2) NOT NULL,
    disbursement_mode ENUM('CASH', 'CHEQUE', 'NEFT', 'RTGS', 'IMPS', 'UPI') NOT NULL,
    transaction_reference VARCHAR(100),
    bank_account_number VARCHAR(30),
    bank_ifsc VARCHAR(11),
    disbursed_by_employee_id INT NOT NULL,
    disbursement_date DATE NOT NULL,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id),
    FOREIGN KEY (disbursed_by_employee_id) REFERENCES employees(employee_id),
    INDEX idx_loan (loan_id),
    INDEX idx_disbursement_date (disbursement_date)
);

-- 8. PAYMENT & REPAYMENT MANAGEMENT

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    payment_reference VARCHAR(50) UNIQUE NOT NULL,
    loan_id INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(15,2) NOT NULL,
    principal_paid DECIMAL(15,2) NOT NULL,
    interest_paid DECIMAL(15,2) NOT NULL,
    penalty_paid DECIMAL(15,2) DEFAULT 0,
    payment_mode ENUM('CASH', 'CHEQUE', 'NEFT', 'RTGS', 'IMPS', 'UPI', 'DEBIT_CARD') NOT NULL,
    transaction_reference VARCHAR(100),
    received_by_employee_id INT NOT NULL,
    receipt_number VARCHAR(50) UNIQUE,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id),
    FOREIGN KEY (received_by_employee_id) REFERENCES employees(employee_id),
    INDEX idx_loan (loan_id),
    INDEX idx_payment_date (payment_date),
    INDEX idx_payment_reference (payment_reference)
);

-- 9. AUDIT & TRACKING

CREATE TABLE audit_logs (
    audit_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50) NOT NULL,
    record_id INT NOT NULL,
    action_type ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    old_values JSON,
    new_values JSON,
    changed_by_employee_id INT,
    changed_by_user VARCHAR(100),
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (changed_by_employee_id) REFERENCES employees(employee_id),
    INDEX idx_table_record (table_name, record_id),
    INDEX idx_created_at (created_at),
    INDEX idx_employee (changed_by_employee_id)
);

-- 10. VIEWS FOR COMMON QUERIES

-- View: Customer Loan Summary
CREATE VIEW vw_customer_loan_summary AS
SELECT 
    c.customer_id,
    c.customer_code,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.phone,
    c.email,
    COUNT(DISTINCT la.application_id) AS total_applications,
    COUNT(DISTINCT CASE WHEN la.status = 'APPROVED' THEN la.application_id END) AS approved_count,
    COUNT(DISTINCT l.loan_id) AS active_loans,
    COALESCE(SUM(l.outstanding_principal), 0) AS total_outstanding,
    COALESCE(SUM(ga.assessed_value), 0) AS total_collateral_value
FROM customers c
LEFT JOIN loan_applications la ON c.customer_id = la.customer_id
LEFT JOIN loans l ON c.customer_id = l.customer_id AND l.loan_status = 'ACTIVE'
LEFT JOIN gold_assets ga ON c.customer_id = ga.customer_id AND ga.status = 'PLEDGED'
GROUP BY c.customer_id, c.customer_code, c.first_name, c.last_name, c.phone, c.email;

-- View: Application Pipeline
CREATE VIEW vw_application_pipeline AS
SELECT 
    la.application_id,
    la.application_number,
    la.application_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.phone AS customer_phone,
    b.branch_name,
    CONCAT(e.first_name, ' ', e.last_name) AS officer_name,
    ls.scheme_name,
    la.requested_amount,
    la.approved_amount,
    la.status,
    DATEDIFF(CURRENT_DATE, DATE(la.application_date)) AS days_pending,
    (SELECT COUNT(*) FROM loan_approvals lap 
     WHERE lap.application_id = la.application_id 
     AND lap.approval_status = 'APPROVED') AS approvals_completed,
    (SELECT COUNT(*) FROM approval_levels WHERE min_amount <= la.requested_amount 
     AND (max_amount IS NULL OR max_amount >= la.requested_amount)) AS approvals_required
FROM loan_applications la
JOIN customers c ON la.customer_id = c.customer_id
JOIN branches b ON la.branch_id = b.branch_id
JOIN employees e ON la.officer_id = e.employee_id
JOIN loan_schemes ls ON la.scheme_id = ls.scheme_id
WHERE la.status NOT IN ('CANCELLED', 'REJECTED', 'DISBURSED');

-- View: Loan Performance
CREATE VIEW vw_loan_performance AS
SELECT 
    l.loan_id,
    l.loan_account_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    l.principal_amount,
    l.outstanding_principal,
    l.outstanding_interest,
    l.penalty_amount,
    l.emi_amount,
    l.disbursement_date,
    l.maturity_date,
    DATEDIFF(l.maturity_date, CURRENT_DATE) AS days_to_maturity,
    l.loan_status,
    COUNT(p.payment_id) AS payments_made,
    COALESCE(SUM(p.payment_amount), 0) AS total_paid,
    ROUND(((l.principal_amount - l.outstanding_principal) / l.principal_amount) * 100, 2) AS repayment_percentage
FROM loans l
JOIN customers c ON l.customer_id = c.customer_id
LEFT JOIN payments p ON l.loan_id = p.loan_id
GROUP BY l.loan_id, l.loan_account_number, c.first_name, c.last_name,
         l.principal_amount, l.outstanding_principal, l.outstanding_interest,
         l.penalty_amount, l.emi_amount, l.disbursement_date, l.maturity_date, l.loan_status;

-- 11. STORED PROCEDURES

DELIMITER //

-- Procedure: Calculate Eligible Loan Amount
CREATE PROCEDURE sp_calculate_eligible_loan(
    IN p_customer_id INT,
    IN p_scheme_id INT,
    OUT p_collateral_value DECIMAL(15,2),
    OUT p_eligible_amount DECIMAL(15,2)
)
BEGIN
    DECLARE v_ltv_ratio DECIMAL(5,2);
    
    -- Get total collateral value
    SELECT COALESCE(SUM(assessed_value), 0) 
    INTO p_collateral_value
    FROM gold_assets
    WHERE customer_id = p_customer_id 
    AND status = 'AVAILABLE';
    
    -- Get LTV ratio from scheme
    SELECT loan_to_value_ratio 
    INTO v_ltv_ratio
    FROM loan_schemes
    WHERE scheme_id = p_scheme_id;
    
    -- Calculate eligible amount
    SET p_eligible_amount = p_collateral_value * (v_ltv_ratio / 100);
END //

-- Procedure: Process Loan Disbursement
CREATE PROCEDURE sp_disburse_loan(
    IN p_application_id INT,
    IN p_disbursement_mode VARCHAR(20),
    IN p_transaction_ref VARCHAR(100),
    IN p_disbursed_by_employee_id INT,
    OUT p_loan_id INT,
    OUT p_status VARCHAR(50)
)
BEGIN
    DECLARE v_customer_id INT;
    DECLARE v_branch_id INT;
    DECLARE v_approved_amount DECIMAL(15,2);
    DECLARE v_interest_rate DECIMAL(5,2);
    DECLARE v_tenure_months INT;
    DECLARE v_loan_account_number VARCHAR(30);
    DECLARE v_emi_amount DECIMAL(15,2);
    DECLARE v_total_payable DECIMAL(15,2);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status = 'ERROR: Transaction rolled back';
    END;
    
    START TRANSACTION;
    
    -- Get application details
    SELECT customer_id, branch_id, approved_amount, interest_rate, tenure_months
    INTO v_customer_id, v_branch_id, v_approved_amount, v_interest_rate, v_tenure_months
    FROM loan_applications
    WHERE application_id = p_application_id AND status = 'APPROVED';
    
    IF v_approved_amount IS NULL THEN
        SET p_status = 'ERROR: Application not found or not approved';
        ROLLBACK;
    ELSE
        -- Generate loan account number
        SET v_loan_account_number = CONCAT('GL', LPAD(p_application_id, 10, '0'));
        
        -- Calculate EMI (simplified calculation)
        SET v_emi_amount = (v_approved_amount * (1 + (v_interest_rate/100) * (v_tenure_months/12))) / v_tenure_months;
        SET v_total_payable = v_emi_amount * v_tenure_months;
        
        -- Create loan record
        INSERT INTO loans (
            loan_account_number, application_id, customer_id, branch_id,
            principal_amount, interest_rate, tenure_months, emi_amount,
            total_payable, disbursement_date, maturity_date, outstanding_principal
        ) VALUES (
            v_loan_account_number, p_application_id, v_customer_id, v_branch_id,
            v_approved_amount, v_interest_rate, v_tenure_months, v_emi_amount,
            v_total_payable, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL v_tenure_months MONTH),
            v_approved_amount
        );
        
        SET p_loan_id = LAST_INSERT_ID();
        
        -- Create disbursement record
        INSERT INTO disbursements (
            loan_id, disbursement_amount, disbursement_mode,
            transaction_reference, disbursed_by_employee_id, disbursement_date
        ) VALUES (
            p_loan_id, v_approved_amount, p_disbursement_mode,
            p_transaction_ref, p_disbursed_by_employee_id, CURRENT_DATE
        );
        
        -- Update application status
        UPDATE loan_applications 
        SET status = 'DISBURSED'
        WHERE application_id = p_application_id;
        
        -- Update gold assets status
        UPDATE gold_assets ga
        JOIN application_assets aa ON ga.asset_id = aa.asset_id
        SET ga.status = 'PLEDGED'
        WHERE aa.application_id = p_application_id;
        
        SET p_status = 'SUCCESS: Loan disbursed';
        COMMIT;
    END IF;
END //

DELIMITER ;

-- 12. COMPLEX BUSINESS QUERIES

-- Query 1: Top 10 customers by outstanding loan amount
SELECT customer_name, customer_phone, active_loans, total_outstanding, total_collateral_value
FROM vw_customer_loan_summary
WHERE active_loans > 0
ORDER BY total_outstanding DESC
LIMIT 10;

-- Query 2: Branch-wise loan performance
SELECT 
b.branch_name,
COUNT(DISTINCT l.loan_id) AS total_loans,
SUM(l.principal_amount) AS total_disbursed,
SUM(l.outstanding_principal) AS total_outstanding,
AVG(DATEDIFF(CURRENT_DATE, l.disbursement_date)) AS avg_loan_age_days,
COUNT(DISTINCT CASE WHEN l.loan_status = 'OVERDUE' THEN l.loan_id END) AS overdue_loans
FROM branches b
LEFT JOIN loans l ON b.branch_id = l.branch_id
GROUP BY b.branch_id, b.branch_name
ORDER BY total_disbursed DESC;

-- Query 3: Application approval funnel
SELECT 
status,
COUNT(*) AS count,
AVG(DATEDIFF(CURRENT_DATE, application_date)) AS avg_days_in_status,
SUM(requested_amount) AS total_amount
FROM loan_applications
WHERE application_date >= DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH)
GROUP BY status
ORDER BY FIELD(status, 'DRAFT', 'SUBMITTED', 'UNDER_REVIEW', 'PENDING_APPROVAL', 'APPROVED', 'REJECTED', 'DISBURSED');

-- 13. INDEXES FOR PERFORMANCE OPTIMIZATION

-- Additional composite indexes for complex queries
CREATE INDEX idx_loans_customer_status ON loans(customer_id, loan_status);
CREATE INDEX idx_applications_branch_status ON loan_applications(branch_id, status);
CREATE INDEX idx_payments_loan_date ON payments(loan_id, payment_date);
CREATE INDEX idx_assets_customer_status ON gold_assets(customer_id, status);

-- END OF SCHEMA
