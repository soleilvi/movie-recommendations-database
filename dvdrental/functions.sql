-- Concatenate the first and last name columns for the summary table
CREATE OR REPLACE FUNCTION get_full_name(first_name character varying(45), last_name character varying(45))
RETURNS character varying(91)
AS $$
	SELECT concat(first_name, ' ', last_name)
$$ LANGUAGE SQL;

-- Returns customer recommendations in a format compatible with the recommendation table
CREATE OR REPLACE FUNCTION get_customer_recommendations(curr_customer_id int)
RETURNS TABLE (customer_id integer, 
			   recommendation_1 character varying(255), 
			   recommendation_2 character varying(255), 
			   recommendation_3 character varying(255), 
			   recommendation_4 character varying(255), 
			   recommendation_5 character varying(255))
AS $$
	SELECT * 
	FROM crosstab('SELECT '||curr_customer_id||' AS customer_id,
				   		ROW_NUMBER() OVER() AS ranking,
				  		recommended_movie
				   FROM generate_customer_recommendations('||curr_customer_id||')')
	AS pee(customer_id integer,
		   recommendation_1 character varying(255),
		   recommendation_2 character varying(255),
		   recommendation_3 character varying(255),
		   recommendation_4 character varying(255),
		   recommendation_5 character varying(255))
$$ LANGUAGE SQL;

-- Retrieve the top five customer recommendations based on the genre, actors, and rating of the movies they have watched previously
CREATE OR REPLACE FUNCTION generate_customer_recommendations(curr_customer_id int)
RETURNS TABLE (recommended_movie character varying(255))
AS $$
	SELECT film.title
	FROM film_actor
	INNER JOIN film
	-- Get only movies with the rating the customer has rented out the most
	ON film.film_id = film_actor.film_id 
		AND film.rating = get_preferred_rating(curr_customer_id)
	INNER JOIN film_category
	-- Get only movies with the category the customer has rented out the most
	ON film_actor.film_id = film_category.film_id 
		AND film_category.category_id = get_preferred_category(curr_customer_id)
	WHERE film_actor.actor_id IN
	(
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
		WHERE customer.customer_id = curr_customer_id
		GROUP BY actor_id
	)
		AND film_actor.film_id NOT IN
	(
		-- Selects the IDs of the films a customer has previously rented out
		SELECT film.film_id
		FROM customer
		INNER JOIN rental
		ON customer.customer_id = rental.customer_id 
		INNER JOIN inventory
		ON rental.inventory_id = inventory.inventory_id
		INNER JOIN film
		ON inventory.film_id = film.film_id
		WHERE customer.customer_id = curr_customer_id
	)
	GROUP BY film_actor.film_id, film.title, film_category.category_id, film.rating
	ORDER BY COUNT(film_actor.actor_id) DESC
	LIMIT 5
$$ LANGUAGE SQL;

-- Returns the rating that the customer has rented out the most
CREATE OR REPLACE FUNCTION get_preferred_rating(curr_customer_id INT)
RETURNS mpaa_rating
AS $$
	SELECT film.rating
	FROM customer
	INNER JOIN rental
	ON customer.customer_id = rental.customer_id 
	INNER JOIN inventory
	ON rental.inventory_id = inventory.inventory_id
	INNER JOIN film
	ON inventory.film_id = film.film_id
	WHERE customer.customer_id = curr_customer_id
	GROUP BY film.rating
	ORDER BY COUNT(film.rating) DESC
	LIMIT 1
$$ LANGUAGE SQL;

-- Returns the category that the customer has rented out the most
CREATE OR REPLACE FUNCTION get_preferred_category(curr_customer_id INT)
RETURNS smallint
AS $$
	SELECT film_category.category_id
	FROM customer
	INNER JOIN rental
	ON customer.customer_id = rental.customer_id 
	INNER JOIN inventory
	ON rental.inventory_id = inventory.inventory_id
	INNER JOIN film
	ON inventory.film_id = film.film_id
	INNER JOIN film_category
	ON film.film_id = film_category.film_id
	WHERE customer.customer_id = curr_customer_id
	GROUP BY film_category.category_id
	ORDER BY COUNT(film_category.category_id) DESC
	LIMIT 1
$$ LANGUAGE SQL;

SELECT get_preferred_category(1);
SELECT get_preferred_rating(1);
SELECT * FROM generate_customer_recommendations(38);
SELECT * FROM get_customer_recommendations(38);
SELECT get_full_name('John', 'Doe');