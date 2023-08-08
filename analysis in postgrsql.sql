-- Q1: Who is the senior most employee based on job title? 

SELECT employee_id,last_name,first_name, title
FROM employee
WHERE title = (
    SELECT MAX(title) 
    FROM employee
);

-- Q2: Which countries have the most Invoices? 

SELECT billing_country, COUNT(*) AS num_invoices
FROM invoice
GROUP BY billing_country
ORDER BY num_invoices DESC;

-- Q3: What are top 3 values of total invoice? 

SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3;

-- Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. 
 --Return both the city name & sum of all invoice totals --
 
ALTER TABLE invoice ALTER COLUMN total TYPE numeric USING (total::numeric);
 
SELECT billing_city, SUM(total) AS invoice_totals FROM Invoice
GROUP BY billing_City
ORDER BY invoice_totals DESC
LIMIT 1;

 -- Who is the best customer? The customer who has spent the most money will be declared the best customer. 
 -- Write a query that returns the person who has spent the most money.
 
 ALTER TABLE invoice ALTER COLUMN invoice_id TYPE integer USING (total::integer);
 
SELECT c.customer_id, c.first_name, c.last_name, SUM(inv.unit_price) AS invoices
FROM invoice i
JOIN customer c
ON i.customer_id = c.customer_id
JOIN invoice_line inv
ON inv.invoice_id = i.invoice_id 
GROUP BY c.Customer_Id, c.First_Name,c.Last_Name
ORDER BY invoices DESC
LIMIT 1;

-- Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A.

ALTER TABLE track ALTER COLUMN track_id TYPE integer USING (track_id::integer);

ALTER TABLE track ALTER COLUMN genre_id TYPE integer USING (genre_id::integer);

SELECT c.email, c.first_name, c.last_name, g.name
FROM invoice i
JOIN customer c
ON i.customer_id = c.customer_id
JOIN invoice_line inv
ON inv.invoice_id = i.invoice_id 
JOIN track t
ON t.track_id = inv.track_id
JOIN genre g
ON g.genre_id = t.genre_id
WHERE g.name = 'Rock'
ORDER BY email;

-- Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands

ALTER TABLE track ALTER COLUMN album_id TYPE integer USING (album_id::integer);


SELECT art.name as artist_name, COUNT(pl.track_id) AS total_track_count
FROM track t
JOIN playlist_track pl
ON t.track_id = pl.track_id
JOIN album a
ON t.album_id = a.album_id
JOIN artist art
ON art.artist_id = a.artist_id
GROUP BY art.name
ORDER BY total_track_count DESC
LIMIT 10;

/* Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.*/

ALTER TABLE track ALTER COLUMN Milliseconds TYPE integer USING (Milliseconds::integer);

SELECT name track_name, AVG(Milliseconds) Average_of_song_length
FROM track t
GROUP BY 1
ORDER BY 2 DESC;
--or 
SELECT name track_name, Milliseconds
FROM track 
WHERE milliseconds > (
	SELECT AVG(Milliseconds) AS avg_track_length
	FROM track )
ORDER BY 2 DESC;
 


/* Q1: Find how much amount spent by each customer on artists? Write a query to return 
customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. 
Now use this artist to find which customer spent the most on this artist. For this query, you 
will need to use the Invoice, InvoiceLine, Track, Customer, Album, and Artist tables. Note, 
this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and 
then multiply this by the price
for each artist. */

WITH best_selling_artist AS (
	SELECT a.artist_id artist_id, a.name artist_name, SUM(il.unit_price*il.quantity) total_sales
	FROM invoice_line il
	JOIN track t ON t.track_id = il.track_id
	JOIN album al ON al.album_id = t.album_id
	JOIN artist a ON a.artist_id = al.artist_id
	GROUP BY 1,2
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;
	
/* Q2: We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all Genres. */

WITH t1 AS (    
	            SELECT g.name genre_name, c.country, COUNT(i.invoice_id) purchase, g.genre_id
	            FROM customer c
				JOIN invoice i
				ON c.customer_id = i.customer_id
				JOIN invoice_line il
				ON il.invoice_id = i.invoice_id
				JOIN track t
				ON t.track_id = il.track_id
				JOIN genre g
				ON g.genre_id = t.genre_id
				GROUP BY 1, 2, 4
				ORDER BY 3 DESC
				 )
SELECT t1.* 
FROM t1
JOIN (
		SELECT MAX(purchase) Maxpurchase, country, genre_name, genre_id
		FROM t1 
		GROUP BY country, genre_name, genre_id
        )t2
ON t1.country = t2.country
WHERE t1.purchase = t2.Maxpurchase;

/*Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH t1 AS	(SELECT c.country, SUM(i.total) total_spent, c.first_name, c.last_name, c.customer_id 
			FROM customer c
			JOIN invoice i
			ON i.customer_id = c.customer_id
			GROUP BY 1,3, 4, 5
			 )
			 SELECT t1.*
			 FROM t1
			 JOIN (SELECT country, MAX(total_spent) Max_spent, first_name, last_name, customer_id 
			 FROM t1
			 GROUP BY 1,3, 4, 5
			 )t2
			 ON t1.country = t1.country
			 WHERE t1.total_spent = t2.Max_spent
			 ORDER BY country;


