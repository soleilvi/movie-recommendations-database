-- Holds all the recommendations for the customers based on their rental history
CREATE TABLE recommendation
(
	customer_id integer NOT NULL,
	recommendation_1 character varying(255),
    recommendation_2 character varying(255),
    recommendation_3 character varying(255),
    recommendation_4 character varying(255),
    recommendation_5 character varying(255),
	last_update timestamp without time zone NOT NULL DEFAULT now(),
	PRIMARY KEY (customer_id),    
    FOREIGN KEY (customer_id) REFERENCES public.customer (customer_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- For last_udpdate
CREATE OR REPLACE TRIGGER last_updated
    BEFORE UPDATE 
    ON public.recommendation
    FOR EACH ROW
    EXECUTE FUNCTION public.last_updated();

-- Fill table
do $$ 
declare 
	counter integer := 1;
begin 
	while counter <= (SELECT COUNT(customer_id) FROM customer) loop 
		INSERT INTO recommendation (customer_id, recommendation_1, recommendation_2, recommendation_3, recommendation_4, recommendation_5)
		SELECT * FROM get_customer_recommendations(counter);
		counter := counter + 1;
	end loop;
end; $$;

-- Query
SELECT *
FROM recommendation
ORDER BY customer_id;