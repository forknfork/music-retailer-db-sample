--Which tracks appeared in the most playlists? How many playlists did they appear in?

SELECT tracks.name, COUNT(DISTINCT PlaylistId) as '# of Playlists'
FROM tracks
JOIN playlist_track
	ON tracks.TrackID = playlist_track.TrackId
GROUP BY tracks.TrackId
ORDER BY 2 DESC
LIMIT 40;

-- Which Which track generated the most revenue?

SELECT tracks.Name, SUM(invoice_items.UnitPrice) as 'Total Revenue'
FROM tracks
JOIN invoice_items
	ON tracks.TrackId = invoice_items.TrackId
GROUP BY tracks.TrackId
ORDER BY 2 DESC
LIMIT 40;

--Which album generated the most revenue?

SELECT albums.Title, SUM(invoice_items.UnitPrice) as 'Total Revenue'
FROM tracks
JOIN invoice_items
	ON tracks.TrackId = invoice_items.TrackId
	JOIN albums
		ON tracks.AlbumID = albums.ALbumID
GROUP BY albums.AlbumID
ORDER BY 2 DESC
LIMIT 10;

--Which genre generated the most revenue?

SELECT genres.name, ROUND(SUM(invoice_items.UnitPrice),2) as 'Total Revenue'
FROM tracks
JOIN invoice_items
	ON tracks.TrackId = invoice_items.TrackId
	JOIN genres
		ON tracks.GenreID = genres.GenreId
GROUP BY genres.GenreID
ORDER BY 2 DESC
LIMIT 10;

--How many customers did each employee support, what is the average revenue for each sale, and what is their total sale?

SELECT employees.EmployeeId, 
	employees.FirstName, 
	employees.LastName, 
	COUNT(DISTINCT customers.CustomerId) AS 'Customers Helped', 
	ROUND(SUM(invoices.Total),2) AS 'Total Support Revenue', 
	ROUND(AVG(invoices.Total),2) AS 'Average Support Revenue'
FROM employees 
	LEFT JOIN customers 
		ON employees.EmployeeID = customers.SupportRepId
		LEFT JOIN invoices 
			ON invoices.CustomerId = customers.CustomerId
GROUP BY EmployeeID;

---Do longer or shorter length albums tend to generate more revenue?

SELECT albums.AlbumId,
	albums.Title,
	artists.Name,
	sum(tracks.Milliseconds)/1000 AS 'Seconds',
	sum(invoice_items.UnitPrice * invoice_items.Quantity) AS 'Revenue',
	round(sum(invoice_items.UnitPrice * invoice_items.Quantity) / (sum(tracks.Milliseconds)/1000), 5) AS '$/Sec'
FROM albums 
	LEFT JOIN artists ON albums.ArtistId = artists.ArtistId
	JOIN tracks ON albums.AlbumId = tracks.AlbumId
	JOIN invoice_items ON invoice_items.TrackId = tracks.TrackId
GROUP BY albums.AlbumId
ORDER BY Seconds DESC;

-- Is the number of times a track appear in any playlist a good indicator of sales?

SELECT 
	tracks.TrackId,
	tracks.Name AS 'Track',
	artists.Name AS 'Artist',
	count(DISTINCT playlist_track.PlaylistId) AS 'Playlists',
	sum(invoice_items.quantity) AS 'Units Sold'
FROM tracks
	JOIN albums ON tracks.AlbumID = albums.AlbumId
		JOIN artists ON albums.ArtistId = artists.ArtistId
			JOIN invoice_items ON invoice_items.TrackId = tracks.TrackId
				JOIN playlist_track ON playlist_track.TrackId = tracks.TrackId
GROUP BY tracks.TrackId
ORDER BY 5 DESC;

-- How much revenue is generated each year, and what is its percent change from the previous year? 
WITH past AS (
	SELECT 
		strftime('%Y',invoices.InvoiceDate) + 1 AS previous_year,
		SUM(invoices.Total) AS previous_sales
	FROM invoices
	GROUP BY previous_year
),
later AS (
	SELECT 
		strftime('%Y',invoices.InvoiceDate) AS recent_year,
		SUM(invoices.Total) AS recent_sales
	FROM invoices
	GROUP BY recent_year
)
SELECT 
	recent_year AS 'Year',
	recent_sales AS 'Total Sales',
	ROUND((((recent_sales - previous_sales) / previous_sales) * 100),2) AS 'Percentage Change'
FROM past
JOIN later ON CAST(previous_year AS int) = CAST(recent_year AS int)
GROUP BY 1;
