-- Detailed table
CREATE TABLE detailed_customer_rental_info
(
	customer_id integer NOT NULL,
	rental_id integer NOT NULL,
	inventory_id integer,
	film_id integer,
	category_id smallint,
	actor_id smallint NOT NULL,
	first_name character varying(45),
	last_name character varying(45),
	email character varying(50),
	title character varying(255),
	rating mpaa_rating,
	recommendation_1 character varying(255),
	recommendation_2 character varying(255),
	recommendation_3 character varying(255),
	recommendation_4 character varying(255),
	recommendation_5 character varying(255),
	last_update timestamp without time zone NOT NULL DEFAULT now(),
	PRIMARY KEY (customer_id, rental_id, actor_id),
	FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	FOREIGN KEY (rental_id) REFERENCES rental(rental_id)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id)
		ON UPDATE CASCADE
		ON DELETE RESTRICT,
	FOREIGN KEY (film_id) REFERENCES film(film_id)
		ON UPDATE CASCADE
		ON DELETE RESTRICT,
	FOREIGN KEY (category_id) REFERENCES category(category_id)
		ON UPDATE CASCADE
		ON DELETE RESTRICT,
	FOREIGN KEY (actor_id) REFERENCES actor(actor_id)
		ON UPDATE CASCADE
		ON DELETE RESTRICT
);

-- For last_update
CREATE OR REPLACE TRIGGER last_updated
    BEFORE UPDATE 
    ON public.detailed_customer_rental_info
    FOR EACH ROW
    EXECUTE FUNCTION public.last_updated();
	
-- Query
SELECT *
FROM detailed_customer_rental_info;
