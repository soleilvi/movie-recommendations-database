-- Refreshes the detailed_customer_rental_info table by deleting all rows and adding new ones back in
CREATE OR REPLACE PROCEDURE refresh_detailed_and_summary_tables()
AS $$
	-- DETAILED TABLE
	TRUNCATE TABLE detailed_customer_rental_info;
	TRUNCATE TABLE mailing_list_recommendation;
	
	INSERT INTO detailed_customer_rental_info
	SELECT customer.customer_id, 
		   rental.rental_id,
		   inventory.inventory_id, 
		   film.film_id, 
		   film_category.category_id, 
		   film_actor.actor_id, 
		   customer.first_name, 
		   customer.last_name, 
		   customer.email, 
		   film.title, 
		   film.rating,
		   recommendation.recommendation_1,
		   recommendation.recommendation_2,
		   recommendation.recommendation_3,
		   recommendation.recommendation_4,
		   recommendation.recommendation_5
	FROM customer
	INNER JOIN rental
	ON customer.customer_id = rental.customer_id 
	INNER JOIN recommendation
	ON customer.customer_id = recommendation.customer_id
	INNER JOIN inventory
	ON rental.inventory_id = inventory.inventory_id
	INNER JOIN film
	ON inventory.film_id = film.film_id
	INNER JOIN film_category
	ON film.film_id = film_category.film_id
	INNER JOIN film_actor
	ON film.film_id = film_actor.film_id;
$$ LANGUAGE SQL;

-- Insert a new row into recommendation 
CREATE OR REPLACE PROCEDURE insert_into_recommendation(new_customer_id int)
AS $$
	INSERT INTO recommendation (customer_id)
	VALUES (new_customer_id);
$$ LANGUAGE SQL;

-- Update a row in recommendation 
CREATE OR REPLACE PROCEDURE update_recommendation(curr_customer_id int)
AS $$
	UPDATE recommendation
    SET recommendation_1 = src.recommendation_1,
		recommendation_2 = src.recommendation_2,
		recommendation_3 = src.recommendation_3,
		recommendation_4 = src.recommendation_4,
		recommendation_5 = src.recommendation_5
	FROM get_customer_recommendations(curr_customer_id) AS src
	WHERE recommendation.customer_id = curr_customer_id;
$$ LANGUAGE SQL;

-- Insert a new row into detailed_customer_rental_info
CREATE OR REPLACE PROCEDURE insert_into_detailed_customer_rental_info(new_customer_id int, new_rental_id int)
AS $$	
	INSERT INTO detailed_customer_rental_info
	SELECT customer.customer_id, 
		   rental.rental_id,
		   inventory.inventory_id, 
		   film.film_id, 
		   film_category.category_id, 
		   film_actor.actor_id, 
		   customer.first_name, 
		   customer.last_name, 
		   customer.email, 
		   film.title, 
		   film.rating,
		   recommendation.recommendation_1,
		   recommendation.recommendation_2,
		   recommendation.recommendation_3,
		   recommendation.recommendation_4,
		   recommendation.recommendation_5
	FROM customer
	INNER JOIN rental
	ON customer.customer_id = rental.customer_id 
	INNER JOIN recommendation
	ON customer.customer_id = recommendation.customer_id
	INNER JOIN inventory
	ON rental.inventory_id = inventory.inventory_id
	INNER JOIN film
	ON inventory.film_id = film.film_id
	INNER JOIN film_category
	ON film.film_id = film_category.film_id
	INNER JOIN film_actor
	ON film.film_id = film_actor.film_id
	WHERE customer.customer_id = new_customer_id
		AND rental.rental_id = new_rental_id;
$$ LANGUAGE SQL;

-- Update only the recommendations in mailing_list_recommendation
CREATE OR REPLACE PROCEDURE update_mailing_list_recommendation(new_customer_id int)
AS $$
	UPDATE mailing_list_recommendation AS mlr
	SET recommendation_1 = r.recommendation_1,
	    recommendation_2 = r.recommendation_2,
		recommendation_3 = r.recommendation_3,
		recommendation_4 = r.recommendation_4,
		recommendation_5 = r.recommendation_5
	FROM recommendation AS r
	WHERE mlr.customer_id = r.customer_id AND mlr.customer_id = new_customer_id;
$$ LANGUAGE SQL;