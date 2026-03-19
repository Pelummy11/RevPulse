---Ingesting the data--
COPY accounts(account_id, account_name, industry, company_size, created_at)
FROM '/path/to/accounts.csv' CSV HEADER;

COPY customers(customer_id, account_id, email, role, created_at)
FROM '/path/to/customers.csv' CSV HEADER;

-- Repeat for all tables