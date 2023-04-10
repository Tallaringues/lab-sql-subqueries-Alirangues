-- Lab | SQL Subqueries 3.03 --
-- Week3 - Day1 - Afternoon
USE sakila;

-- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT * FROM inventory;
SELECT * FROM film;

-- step1
SELECT film_id FROM film
WHERE title = 'Hunchback Impossible';

-- full query
SELECT COUNT(film_id) FROM inventory
WHERE film_id = (SELECT film_id FROM film
WHERE title = 'Hunchback Impossible'
);

-- List all films whose length is longer than the average of all the films.
SELECT * FROM film;

SELECT ROUND(AVG(length),2) AS 'Averge' FROM film;

SELECT * FROM film
WHERE length > (SELECT ROUND(AVG(length),2) AS 'Averge' 
FROM film
)
ORDER BY length DESC; -- This extra part was for my to check


-- Use subqueries to display all actors who appear in the film Alone Trip.

SELECT CONCAT(first_name, ' ', last_name) AS Actor FROM actor
WHERE actor_id IN (
	SELECT actor_id FROM film_actor
	WHERE film_id = (
		SELECT film_id FROM film
		WHERE title = 'Alone trip') ) ;

-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT * FROM film_category;
SELECT * FROM category;

SELECT category_id FROM category
WHERE name = 'Family';

SELECT title FROM film
WHERE film_id IN (
	SELECT film_id FROM film_category
	WHERE category_id =
		(SELECT category_id FROM category
		WHERE name = 'Family'
	));

-- Get name and email from customers from Canada using subqueries. 
-- Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
SELECT country_id FROM country
WHERE country = 'Canada';

SELECT city_id FROM city
WHERE country_id = 
	(SELECT country_id FROM country
	WHERE country = 'Canada'
	);
    
SELECT address_id FROM address
WHERE city_id IN (SELECT city_id FROM city
	WHERE country_id = 
		(SELECT country_id FROM country
		WHERE country = 'Canada'
		));
        
SELECT CONCAT(first_name, ' ', last_name) AS Customer, email FROM customer
WHERE address_id IN (
	SELECT address_id FROM address
	WHERE city_id IN (SELECT city_id FROM city
	WHERE country_id = 
		(SELECT country_id FROM country
		WHERE country = 'Canada'
		)));
        
-- Joins
SELECT CONCAT(cu.first_name, ' ', cu.last_name) AS Customer, cu.email
FROM customer AS cu
JOIN address as ad
ON cu.address_id = ad.address_id
JOIN city as ci
ON ad.city_id = ci.city_id
JOIN country as co
ON ci.country_id = co.country_id
WHERE co.country = 'Canada';


-- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films.
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
SELECT * FROM film;
SELECT * FROM film_actor;

SELECT actor_id, COUNT(film_id) AS num_films FROM film_actor
group by actor_id
ORDER BY num_films DESC
LIMIT 1;

SELECT actor_id FROM
(SELECT actor_id, COUNT(film_id) AS num_films FROM film_actor
group by actor_id
ORDER BY num_films DESC
LIMIT 1
) as sub1;

SELECT film_id FROM film_actor
WHERE actor_id =
	(SELECT actor_id FROM
		(SELECT actor_id, COUNT(film_id) AS num_films FROM film_actor
		group by actor_id
		ORDER BY num_films DESC
		LIMIT 1
		) as sub1
);

-- FINAL QUERY
SELECT title FROM film
WHERE film_id IN (
	SELECT film_id FROM film_actor
	WHERE actor_id =
		(SELECT actor_id FROM
			(SELECT actor_id, COUNT(film_id) AS num_films FROM film_actor
			group by actor_id
			ORDER BY num_films DESC
			LIMIT 1
			) as sub1
	)
);



-- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
SELECT * FROM payment;
SELECT * FROM customer;

SELECT customer_id, round(sum(amount),2) AS total_spent FROM payment
group by customer_id
ORDER by total_spent DESC
LIMIT 1;

SELECT customer_id FROM
	(SELECT customer_id, round(sum(amount),2) AS total_spent FROM payment
	group by customer_id
	ORDER by total_spent DESC
	LIMIT 1
	) as sub1;
    
SELECT inventory_id FROM rental
WHERE customer_id = 
		(SELECT customer_id FROM
			(SELECT customer_id, round(sum(amount),2) AS total_spent FROM payment
			group by customer_id
			ORDER by total_spent DESC
			LIMIT 1
			) as sub1
);

SELECT film_id from inventory
WHERE inventory_id IN (
	SELECT inventory_id FROM rental
WHERE customer_id = 
		(SELECT customer_id FROM
			(SELECT customer_id, round(sum(amount),2) AS total_spent FROM payment
			group by customer_id
			ORDER by total_spent DESC
			LIMIT 1
		) as sub1
	)
);

-- FINAL QUERY
SELECT title FROM film
WHERE film_id IN (
	SELECT film_id from inventory
WHERE inventory_id IN (
	SELECT inventory_id FROM rental
WHERE customer_id = 
		(SELECT customer_id FROM
			(SELECT customer_id, round(sum(amount),2) AS total_spent FROM payment
			group by customer_id
			ORDER by total_spent DESC
			LIMIT 1
			) as sub1
		)
	)
);

-- Customers who spent more than the average payments

SELECT CONCAT(first_name, ' ', last_name) AS Customer FROM customer
	WHERE customer_id IN (
	SELECT DISTINCT customer_id FROM payment
	WHERE amount > (
		SELECT ROUND(AVG(amount),2) AS 'Averge' 
		FROM payment
		)
	);
