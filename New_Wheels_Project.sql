Use new_world
SELECT
	c.state,
	COUNT(DISTINCT c.customer_id) AS total_customer_per_state
FROM
	customer_t c
JOIN
	order_t o USING(customer_id)
WHERE
	quantity > 0
GROUP BY
   	 c.state
ORDER BY
   	 c.state ASC;
    
    SELECT
	COUNT(customer_id)
FROM
	Order_t;
    
    WITH maker_total AS (
    SELECT
        product_id,
        vehicle_maker,
        SUM(quantity) OVER(PARTITION BY vehicle_maker) AS total_units
    FROM
        order_t o
    JOIN
        product_t p USING(product_id)
    WHERE
        quantity > 0)

SELECT
    vehicle_maker,
    MAX(total_units) AS total_units,
    RANK() OVER (ORDER BY MAX(total_units) DESC) as sales_rank
FROM
    maker_total
GROUP BY
    vehicle_maker
ORDER BY
    sales_rank ASC
LIMIT 5;

WITH vehicle_rank AS (
    SELECT
        c.state,
        p.vehicle_maker,
        COUNT(c.customer_id) AS total_sales_state,
        RANK() OVER(
            PARTITION BY c.state
            ORDER BY COUNT(c.customer_id) DESC) AS state_rank
    FROM customer_t c
    JOIN order_t o USING(customer_id)
    JOIN product_t p USING(product_id)
    GROUP BY c.state, p.vehicle_maker)

SELECT *
FROM 
vehicle_rank
WHERE 
state_rank = 1
ORDER BY 
state;

WITH num_ratings AS (
SELECT
	quarter_number,
	CASE 
		WHEN customer_feedback = 'very bad' THEN 1
        WHEN customer_feedback = 'bad' THEN 2
        WHEN customer_feedback = 'okay' THEN 3
        WHEN customer_feedback = 'good' THEN 4
        WHEN customer_feedback = 'very good' THEN 5
        END AS rate
FROM
	order_t)

SELECT
	AVG(rate)
FROM
	num_ratings;

SELECT
	quarter_number,
    AVG(rate) AS avg_per_quarter
FROM
	num_ratings
GROUP BY
	quarter_number
ORDER BY
	quarter_number;

SELECT
    quarter_number,
    (SUM(CASE WHEN customer_feedback = 'very bad' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*)) AS pct_very_bad,
    (SUM(CASE WHEN customer_feedback = 'bad' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*)) AS pct_bad,
    (SUM(CASE WHEN customer_feedback = 'okay' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*)) AS pct_okay,
    (SUM(CASE WHEN customer_feedback = 'good' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*)) AS pct_good,
    (SUM(CASE WHEN customer_feedback = 'very good' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*)) AS pct_very_good
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;

SELECT
	quarter_number,
	COUNT(quantity) AS total_sold
FROM
	order_t
GROUP BY
	quarter_number
ORDER BY
	quarter_number;

SELECT
	SUM(quantity * (vehicle_price-discount)) AS total_rev
FROM
	order_t;
    
WITH vehicle_rev AS (
		SELECT
		quarter_number,
		SUM(quantity * (vehicle_price-discount)) AS total_rev
	FROM
		order_t
	GROUP BY
		quarter_number
	ORDER BY
		quarter_number)
        
SELECT
	quarter_number,
	 LAG(total_rev) OVER (ORDER BY quarter_number) AS prev_rev,
      ( (total_rev - LAG(total_rev) OVER (ORDER BY quarter_number))
      / LAG(total_rev) OVER (ORDER BY quarter_number) ) * 100 AS percentage
FROM
	vehicle_rev
ORDER BY
	quarter_number;

SELECT
	quarter_number,
    SUM(quantity * (vehicle_price-discount)) AS rev,
    COUNT(quantity) as unit_sold
FROM
	order_t
GROUP BY
	quarter_number
ORDER BY
	quarter_number;

SELECT
	c.credit_card_type,
    AVG(o.discount) AS cc_discount
FROM
	customer_t c
JOIN
	order_t o USING(customer_id)
Group BY
	c.credit_card_type;

SELECT
	quarter_number,
	AVG(DATEDIFF(ship_date, order_date )) AS ship_avg
FROM
	order_t
GROUP BY
	quarter_number
ORDER BY
	quarter_number;

