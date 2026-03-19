--Accounts--
CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    account_name TEXT NOT NULL,
    industry TEXT,
    company_size TEXT,
    created_at DATE
);

---Customers---
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    account_id INT REFERENCES accounts(account_id),
    email TEXT,
    role TEXT,
    created_at DATE
);


---Deals---

CREATE TABLE deals (
    deal_id SERIAL PRIMARY KEY,
    account_id INT REFERENCES accounts(account_id),
    deal_value INT,
    stage_id INT,
    status TEXT,
    created_at DATE,
    expected_close_date DATE,
    closed_at DATE,
    attributes JSONB
);


---Activities---
CREATE TABLE activities (
    activity_id SERIAL PRIMARY KEY,
    deal_id INT REFERENCES deals(deal_id),
    activity_type TEXT,
    activity_date DATE,
    details JSONB
);


---Subscriptions---
CREATE TABLE subscriptions (
    subscription_id SERIAL PRIMARY KEY,
    account_id INT REFERENCES accounts(account_id),
    plan_name TEXT,
    start_date DATE,
    end_date DATE,
    status TEXT
);

---Revenue-Transactions--
CREATE TABLE revenue_transactions (
    transaction_id SERIAL PRIMARY KEY,
    subscription_id INT REFERENCES subscriptions(subscription_id),
    amount INT,
    transaction_date DATE,
    type TEXT
);

---Usage Logs--
CREATE TABLE usage_logs (
    usage_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    activity_type TEXT,
    activity_date DATE,
    metadata JSONB
);

---Churn Event---
CREATE TABLE churn_events (
    churn_id SERIAL PRIMARY KEY,
    account_id INT REFERENCES accounts(account_id),
    churn_date DATE,
    reason TEXT
);

-- Deal Stages---
CREATE TABLE deal_stages (
    stage_id INT PRIMARY KEY,
    stage_name TEXT,
    win_probability NUMERIC
);

-- Sales Reps
CREATE TABLE sales_reps (
    rep_id SERIAL PRIMARY KEY,
    rep_name TEXT,
    email TEXT,
    region TEXT
);

-- Update deals table to reference rep_id and stage_id
ALTER TABLE deals
ADD COLUMN rep_id INT 
REFERENCES sales_reps(rep_id);

ALTER TABLE deals
ADD CONSTRAINT fk_stage FOREIGN KEY(stage_id) 
REFERENCES deal_stages(stage_id);


