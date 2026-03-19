---Indexes on foreign keys and datekeys
CREATE INDEX idx_customers_account ON customers(account_id);
CREATE INDEX idx_deals_account ON deals(account_id);
CREATE INDEX idx_activities_deal ON activities(deal_id);
CREATE INDEX idx_usage_customer_date ON usage_logs(customer_id, activity_date);
CREATE INDEX idx_revenue_subscription_date ON revenue_transactions(subscription_id, transaction_date);


CREATE INDEX idx_deals_attributes ON deals USING GIN (attributes);
CREATE INDEX idx_activities_details ON activities USING GIN (details);
CREATE INDEX idx_usage_metadata ON usage_logs USING GIN (metadata);