------------- DEMONSRTRATE FUNCTION SUBSECTIONS -------------
-- Customer rentals sorted by what category they have rented out the most
SELECT film_category.category_id, COUNT(film_category.category_id)
FROM customer
INNER JOIN rental
ON customer.customer_id = rental.customer_id 
INNER JOIN inventory
ON rental.inventory_id = inventory.inventory_id
INNER JOIN film
ON inventory.film_id = film.film_id
INNER JOIN film_category
ON film.film_id = film_category.film_id
WHERE customer.customer_id = 1
GROUP BY film_category.category_id
ORDER BY COUNT(film_category.category_id) DESC;

-- Customer rentals sorted by what rating they have rented out the most
SELECT film.rating, COUNT(film.rating)
FROM customer
INNER JOIN rental
ON customer.customer_id = rental.customer_id 
INNER JOIN inventory
ON rental.inventory_id = inventory.inventory_id
INNER JOIN film
ON inventory.film_id = film.film_id
WHERE customer.customer_id = 1
GROUP BY film.rating
ORDER BY COUNT(film.rating) DESC;

-- Select the actors that have appeared in all the films a customer has rented out
SELECT film_actor.actor_id
FROM customer
INNER JOIN rental
ON customer.customer_id = rental.customer_id 
INNER JOIN inventory
ON inventory.inventory_id = rental.inventory_id
INNER JOIN film
ON film.film_id = inventory.film_id
INNER JOIN film_actor
ON film.film_id = film_actor.film_id
WHERE customer.customer_id = 1
GROUP BY actor_id;

-- Selects the IDs of the films a customer has previously rented out
SELECT film.film_id
FROM customer
INNER JOIN rental
ON customer.customer_id = rental.customer_id 
INNER JOIN inventory
ON rental.inventory_id = inventory.inventory_id
INNER JOIN film
ON inventory.film_id = film.film_id
WHERE customer.customer_id = 1;

-------------- DEMONSRTRATE REFRESH PROCEDURE --------------

-- Fill detailed and summary tables
CALL refresh_detailed_and_summary_tables();

-- Detailed table query
SELECT *
FROM detailed_customer_rental_info
ORDER BY customer_id DESC, last_update DESC;

-- Summary table query
SELECT *
FROM mailing_list_recommendation
ORDER BY customer_id DESC;

--------------- DEMONSRTRATE INSERT TRIGGERS ---------------

INSERT INTO customer
VALUES (600, 1, 'John', 'Smith', 'john.smith@sakilacustomer.com', 1, true);

INSERT INTO rental (rental_id, rental_date, inventory_id, customer_id, return_date, staff_id)
VALUES (16050, '2024-01-01', 2943, 600, '2024-02-01', 1),
	   (16051, '2024-01-01', 1250, 600, '2024-02-01', 1);

-- Rental table
SELECT *
FROM rental
ORDER BY rental_id DESC;

---------------- DEMONSRTRATE UPDATE TRIGGER ---------------
UPDATE detailed_customer_rental_info
SET last_name = 'Doe',
	email = 'john.doe@sakilacustomer.com',
	recommendation_3 = 'Fight Club'
WHERE customer_id = 600;