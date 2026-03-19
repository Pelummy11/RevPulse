---1. Deals activity summary
---What it does:Counts total activities per deal
---Shows last activity date
---Calculates deal age → useful for risk detection

CREATE MATERIALIZED VIEW deal_activity_summary AS
SELECT
    d.deal_id,
    d.account_id,
    d.deal_value,
    d.stage_id,
    d.status,
    COUNT(a.activity_id) AS num_activities,
    MAX(a.activity_date) AS last_activity_date,
	(CURRENT_DATE - d.created_at) AS deal_age_days
FROM deals d
LEFT JOIN activities a ON d.deal_id = a.deal_id
GROUP BY d.deal_id;




---2. A risk scoring function
--What it does:Returns a risk score 0–100 per deal
--Judges can quickly see which deals are “in danger”


CREATE OR REPLACE FUNCTION deal_risk_score(deal_id INT)
RETURNS NUMERIC AS $$
DECLARE
    act_count INT;
    last_act DATE;
    deal_stage INT;
    age_days INT;
    risk NUMERIC := 0;
BEGIN
    SELECT num_activities, last_activity_date, stage_id, deal_age_days
    INTO act_count, last_act, deal_stage, age_days
    FROM deal_activity_summary
    WHERE deal_activity_summary.deal_id = deal_risk_score.deal_id;

    -- fewer activities → higher risk
    IF act_count < 2 THEN
        risk := risk + 30;
    END IF;

    -- deal stagnant >30 days → add risk
    IF last_act IS NULL OR last_act < CURRENT_DATE - INTERVAL '30 days' THEN
        risk := risk + 40;
    END IF;

    -- early stage → more risky
    IF deal_stage IN (1,2) THEN
        risk := risk + 20;
    END IF;

    -- older deals → more risky
    IF age_days > 60 THEN
        risk := risk + 10;
    END IF;

    IF risk > 100 THEN
        risk := 100;
    END IF;

    RETURN risk;
END;
$$ LANGUAGE plpgsql;

SELECT deal_risk_score(10);


---3. Monthly revenue
---Shows monthly recurring revenue (MRR)


CREATE MATERIALIZED VIEW monthly_revenue AS
SELECT
    date_trunc('month', transaction_date) AS month,
    SUM(amount) AS mrr
FROM revenue_transactions
GROUP BY month
ORDER BY month;


---4. Accounts at risk
---Flags accounts most likely to churn
                  
CREATE VIEW churn_risk AS
SELECT
    c.account_id,
    COUNT(u.usage_id) AS recent_activity_count,
    MAX(s.end_date) AS subscription_end,
    MAX(u.activity_date) AS last_activity_date,
    CASE
        WHEN COUNT(u.usage_id) < 50 AND s.status = 'active' THEN 'high_risk'
        WHEN s.status = 'cancelled' THEN 'churned'
        ELSE 'ok'
    END AS churn_status
FROM accounts c
LEFT JOIN customers cu ON c.account_id = cu.account_id
LEFT JOIN usage_logs u ON cu.customer_id = u.customer_id
LEFT JOIN subscriptions s ON c.account_id = s.account_id
WHERE u.activity_date >= CURRENT_DATE - INTERVAL '60 days'
GROUP BY c.account_id, s.status;


---5. Monthly New Customers

CREATE MATERIALIZED VIEW monthly_new_customers AS
SELECT
    date_trunc('month', created_at) AS month,
    COUNT(customer_id) AS new_customers
FROM customers
GROUP BY month
ORDER BY month;

---6. Sales Rep Performance
---Shows rep performance, pipeline coverage, and closed revenue

CREATE VIEW sales_rep_performance AS
SELECT
    r.rep_id,
    r.rep_name,
    COUNT(d.deal_id) AS total_deals,
    SUM(d.deal_value) AS total_pipeline,
    SUM(CASE WHEN d.status='won' THEN d.deal_value ELSE 0 END) AS closed_won_value
FROM sales_reps r
LEFT JOIN deals d ON r.rep_id = d.rep_id
GROUP BY r.rep_id, r.rep_name
ORDER BY closed_won_value DESC;

