-- Summary table
CREATE TABLE mailing_list_recommendation
(
	customer_id integer,
	full_name character varying(91),
	email character varying(50),
	recommendation_1 character varying(255),
	recommendation_2 character varying(255),
	recommendation_3 character varying(255),
	recommendation_4 character varying(255),
	recommendation_5 character varying(255),
	last_update timestamp without time zone NOT NULL DEFAULT now(),
	PRIMARY KEY (customer_id),
	FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
		ON UPDATE CASCADE
  		ON DELETE CASCADE
);

-- For last_update
CREATE OR REPLACE TRIGGER last_updated
    BEFORE UPDATE 
    ON public.mailing_list_recommendation
    FOR EACH ROW
    EXECUTE FUNCTION public.last_updated();

-- Query
SELECT *
FROM mailing_list_recommendation;