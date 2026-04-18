CREATE TABLE rides (
    ride_id INT,
    city VARCHAR(50),
    fare INT,
    status VARCHAR(20),
    timestamp TIMESTAMP
);

SELECT * FROM rides ORDER BY timestamp DESC;

/* ============================================================
   PROJECT: REAL-TIME RIDE ANALYTICS SYSTEM
   DATABASE: PostgreSQL
   ============================================================ */


/* ============================================================
   LEVEL 1: DESCRIPTIVE ANALYSIS (WHAT IS HAPPENING)
   ============================================================ */

-- 1. Total Rides, Revenue, Cancellation Rate
SELECT 
    COUNT(*) AS total_rides,
    SUM(CASE WHEN status = 'completed' THEN fare ELSE 0 END) AS total_revenue,
    ROUND(
        COUNT(*) FILTER (WHERE status = 'cancelled') * 100.0 / COUNT(*), 2
    ) AS cancellation_rate
FROM rides;


-- 2. City-wise Performance
SELECT 
    city,
    COUNT(*) AS total_rides,
    SUM(CASE WHEN status = 'completed' THEN fare ELSE 0 END) AS revenue
FROM rides
GROUP BY city
ORDER BY total_rides DESC;


-- 3. Ride Status Distribution
SELECT 
    status,
    COUNT(*) AS count
FROM rides
GROUP BY status;


-- 4. Average Fare by City
SELECT 
    city,
    ROUND(AVG(fare), 2) AS avg_fare
FROM rides
GROUP BY city;



/* ============================================================
   LEVEL 2: DIAGNOSTIC ANALYSIS (WHY IT IS HAPPENING)
   ============================================================ */

-- 5. Cancellation Analysis by City & Hour
SELECT 
    city,
    EXTRACT(HOUR FROM timestamp) AS hour,
    COUNT(*) AS cancellations
FROM rides
WHERE status = 'cancelled'
GROUP BY city, hour
ORDER BY cancellations DESC;


-- 6. Revenue Loss Due to Cancellation
SELECT 
    city,
    SUM(fare) AS lost_revenue
FROM rides
WHERE status = 'cancelled'
GROUP BY city
ORDER BY lost_revenue DESC;


-- 7. High Fare vs Cancellation Behavior
SELECT 
    CASE 
        WHEN fare > 700 THEN 'High Fare'
        ELSE 'Normal Fare'
    END AS fare_category,
    COUNT(*) FILTER (WHERE status = 'cancelled') AS cancellations,
    COUNT(*) AS total_rides
FROM rides
GROUP BY fare_category;



/* ============================================================
   LEVEL 3: TREND ANALYSIS (WHEN IT HAPPENS)
   ============================================================ */

-- 8. Daily Ride Trend
SELECT 
    DATE(timestamp) AS date,
    COUNT(*) AS total_rides
FROM rides
GROUP BY date
ORDER BY date;


-- 9. Hourly Demand Pattern (Peak Hours)
SELECT 
    EXTRACT(HOUR FROM timestamp) AS hour,
    COUNT(*) AS rides
FROM rides
GROUP BY hour
ORDER BY rides DESC;


-- 10. Recent Demand (Last 5 Minutes)
SELECT 
    city,
    COUNT(*) AS recent_rides
FROM rides
WHERE timestamp >= NOW() - INTERVAL '5 minutes'
GROUP BY city;



/* ============================================================
   LEVEL 4: PRESCRIPTIVE ANALYSIS (WHAT SHOULD WE DO)
   ============================================================ */

-- 11. Surge Pricing Recommendation
SELECT 
    city,
    COUNT(*) AS rides,
    CASE 
        WHEN COUNT(*) > 120 THEN 1.5
        WHEN COUNT(*) > 70 THEN 1.3
        WHEN COUNT(*) > 40 THEN 1.1
        ELSE 1
    END AS surge_multiplier
FROM rides
GROUP BY city;


-- 12. High-Demand Zone Ranking
SELECT 
    city,
    COUNT(*) AS rides,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS demand_rank
FROM rides
GROUP BY city;