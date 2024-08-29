-- Automatically update the recommendation and detailed_customer_rental_info tables when a customer rents out a movie
-- Ensures that the updates are in the correct order
CREATE OR REPLACE FUNCTION insert_on_new_rental()
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN
   IF NEW.customer_id NOT IN (SELECT customer_id FROM recommendation) THEN
       CALL insert_into_recommendation(NEW.customer_id);
   END IF;
   
   CALL update_recommendation(NEW.customer_id);
   CALL insert_into_detailed_customer_rental_info(NEW.customer_id, NEW.rental_id);
   CALL update_mailing_list_recommendation(NEW.customer_id);
   
   RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER insert_on_new_rental
AFTER INSERT ON rental
FOR EACH ROW
EXECUTE PROCEDURE insert_on_new_rental();

-- Automatically update the summary table when a new row is inserted into the detailed table
CREATE OR REPLACE FUNCTION insert_on_new_detailed_info()
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN
	IF NEW.customer_id NOT IN (SELECT customer_id FROM mailing_list_recommendation) THEN
	   INSERT INTO mailing_list_recommendation
	   VALUES (NEW.customer_id,
			   get_full_name(NEW.first_name, NEW.last_name),
			   NEW.email,
			   NEW.recommendation_1,
			   NEW.recommendation_2,
			   NEW.recommendation_3,
			   NEW.recommendation_4,
			   NEW.recommendation_5,
			   NEW.last_update);
	END IF;
	
	RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER insert_on_new_detailed_info
AFTER INSERT ON detailed_customer_rental_info
FOR EACH ROW  
EXECUTE PROCEDURE insert_on_new_detailed_info();

-- Automatically update the summary table when a row changes in the detailed table
CREATE OR REPLACE FUNCTION update_mailing_list_recommendation()
   RETURNS TRIGGER
   LANGUAGE PLPGSQL
AS $$
BEGIN
	UPDATE mailing_list_recommendation
	SET customer_id = NEW.customer_id,
	    full_name = get_full_name(NEW.first_name, NEW.last_name),
		email = NEW.email,
		recommendation_1 = NEW.recommendation_1,
		recommendation_2 = NEW.recommendation_2,
		recommendation_3 = NEW.recommendation_3,
		recommendation_4 = NEW.recommendation_4,
		recommendation_5 = NEW.recommendation_5,
		last_update = NEW.last_update
	WHERE customer_id = NEW.customer_id;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER update_mailing_list_recommendation
AFTER UPDATE ON detailed_customer_rental_info
FOR EACH ROW
EXECUTE PROCEDURE update_mailing_list_recommendation();