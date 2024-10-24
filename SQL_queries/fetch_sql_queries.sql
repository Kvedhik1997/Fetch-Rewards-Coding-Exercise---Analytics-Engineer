-- Fetch SQL query exercise
-- Queries are written in MySQL

-- What are the top 5 brands by receipts scanned for most recent month?
-- How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?

-- This Query provides the ranking of the top 5 brands for the last 2 months and the number of receipts scanned for each of those brands in that month
-- A subquery with DISTINCT was used to ensure each receipt scanned is a single count per brand

SELECT e.ranking, top_brands_2_months_ago, receipts_scanned_2_months_ago, top_brands_last_month, receipts_scanned_last_month
FROM(

	(SELECT ROW_NUMBER() OVER (ORDER BY count(name) DESC) as ranking, name as top_brands_2_months_ago, count(name) as receipts_scanned_2_months_ago
	FROM(
			SELECT DISTINCT receipt_id, c.brandCode, name
			FROM(
				(SELECT *
				FROM schema.receipts
				WHERE YEAR(dateScanned) = YEAR(curdate() - INTERVAL 2 month)
					AND MONTH(dateScanned)= MONTH(curdate()- INTERVAL 2 month)) a
				
				JOIN schema.receipt_items b
				on a.receipt_id=b.receipt_id
				
				JOIN schema.brands c
				on b.brandCode=c.brandCode
				
				)
			WHERE c.brandCode != ''
				and name != '') d
	GROUP BY top_brands_2_months_ago
	ORDER BY receipts_scanned_2_months_ago DESC
	LIMIT 5) e

	JOIN

	(SELECT ROW_NUMBER() OVER (ORDER BY count(name) DESC) as ranking, name as top_brands_last_month, count(name) as receipts_scanned_last_month
	FROM(
			SELECT DISTINCT receipt_id, c.brandCode, name
			FROM(
				(SELECT *
				FROM schema.receipts
				WHERE YEAR(dateScanned) = YEAR(curdate() - INTERVAL 1 month)
					AND MONTH(dateScanned)= MONTH(curdate()- INTERVAL 1 month)) a
				
				JOIN schema.receipt_items b
				on a.receipt_id=b.receipt_id
				
				JOIN schema.brands c
				on b.brandCode=c.brandCode
				
				)
			WHERE c.brandCode != ''
				and name != '') d
	GROUP BY top_brands_last_month
	ORDER BY receipts_scanned_last_month DESC
	LIMIT 5) f
    on e.ranking=f.ranking)




-- When considering average spend FROM receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
-- When considering total number of items purchased FROM receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
-- This query provides the average spent and total number of items purchased by rewards receipt status

SELECT rewardsReceiptStatus, SUM(purchasedItemCount), ROUND(AVG(totalSpent),2)
FROM schema.receipts
GROUP BY rewardsReceiptStatus




-- Which brand has the most spend among users who were created within the past 6 months?
-- This query provides the brand with the highest spend amongst users created in the last 6 months. 

SELECT name as brand_name, sum(finalPrice * quantityPurchased) as total_spend FROM(
	(SELECT *
	FROM schema.users
	WHERE createdDate > curdate() - INTERVAL 6 month) a

	JOIN schema.receipts b
		on  a._id=b.userID
	
    JOIN schema.receipt_items c
	on b._id=c.receipt_id
    
    JOIN schema.brands d
    on c.brandCode=d.brandCode
    )
WHERE name != ''
	AND c.brandCode != ''
GROUP BY name
ORDER BY total_spend DESC
LIMIT 1




-- Which brand has the most transactions among users who were created within the past 6 months?
-- This query provides the brand with the highest number of transactions for usrs created in the last 6 months. 
-- This is how many times the brand showed up on a receipt and does not include extra counts for multiple items FROM the same brand on the receipt
-- A subquery with DISTINCT was used to ensure each receipt scanned is a single count per brand

SELECT name as brand_name, count(name) as transactions 
FROM(
	SELECT DISTINCT receipt_id, c.brandCode, name
    FROM(
		(SELECT *
		FROM schema.users
		WHERE createdDate > curdate() - INTERVAL 6 month) a

		JOIN schema.receipts b
			on  a.user_id=b.user_id
		
		JOIN schema.receipt_items c
			on b.receipt_id=c.receipt_id
		
		JOIN schema.brands d
			on c.brandCode=d.brandCode
		) 
	WHERE name != ''
		AND c.brandCode != '') a
GROUP BY name
ORDER BY transactions DESC
LIMIT 1