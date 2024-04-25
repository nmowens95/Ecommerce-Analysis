USE mavenfuzzyfactory;

-- Analyzing top traffic sources:

-- Looking for number of sessions in first month of sales
SELECT 
	utm_source,
    utm_campaign,
    http_referer,
	COUNT(Distinct website_session_id) AS count_sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY 
	utm_source, 
    utm_campaign, 
    http_referer
ORDER BY count_sessions DESC;
/* gsearch sessions is 3613, then next largest is a null value at 28, thus it isn't
being tracked by our marketing. We'll need to further analyze our gsearch nonbrand */

-- Looking for conversion rate percentage on gsearch, nonbrand
SELECT
	COUNT(DISTINCT w.website_session_id) as sessions,
	COUNT(DISTINCT o.order_id) as orders,
    COUNT(DISTINCT o.order_id)/COUNT(DISTINCT w.website_session_id) AS conv_rate
FROM website_sessions w
LEFT JOIN orders o 
	ON o.website_session_id = w.website_session_id
WHERE w.created_at < '2012-04-14'
	AND w.utm_source = 'gsearch'
    AND w.utm_campaign = 'nonbrand'
;

/* The highest coversion rate percentage was still under 3%. The company is most likely over 
bidding on these campaigns without a good ROI. It is probably best to cut back on these 
campaign expenses, but keep monitoring as well */

-- Trend search analysis of gsearch, nonbrand by week, prior to May 10th 2012
SELECT
	-- YEAR(created_at) AS yr,
    -- WEEK(created_at) AS wk,
	MIN(DATE(created_at)) AS start_of_week,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-05-10'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY
	YEAR(created_at),
    WEEK(created_at)
;
-- session traffic definitely came in lower after lowering bid amount

/* Stakeholder says mobile experience wasn't great for him and wants to see different
conversion rates for desktop vs mobile */
SELECT
    w.device_type,
    COUNT(DISTINCT w.website_session_id) AS sessions,
	COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT w.website_session_id) AS conv_rate
FROM website_sessions w
LEFT JOIN orders o
	ON o.website_session_id = w.website_session_id
WHERE w.created_at < '2012-05-11'
	AND w.utm_source = 'gsearch'
    AND w.utm_campaign = 'nonbrand'
GROUP BY 1
;
/* The mobile conversion rate is less than 1% indicating that our mobile site may not be update
to par. On the other hand our desktop conversion rate is 3.7% in comparison. Thus we probably
shouln't be running the same bids for mobile as we do for desktop */

-- Check the sessions numbers since upping our bid on May 19th, use April 15th as baseline
SELECT
	MIN(DATE(created_at)) week_date,
	COUNT(CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions
FROM website_sessions
WHERE utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
    AND created_at BETWEEN '2012-04-15'
		AND '2012-06-09'
GROUP BY 
	YEAR(created_at),
    WEEK(created_at)

-- Desktop sessions did increase and it looks like bids are having a positive impact on sessions