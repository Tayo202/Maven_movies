use mavenmovies
;
-- -------------1) Name of managers of each store with the store address------------
	SELECT
	store.store_id, staff.first_name AS "Manager first name", 
    staff.last_name AS "Manager last name",
    staff.email AS "Manager Email", address.address, 
    address.district, address.postal_code,
    city.city, country.country
FROM store 
	INNER JOIN staff
					ON store.store_id = staff.store_id 
	INNER JOIN address 
					ON staff.address_id = address.address_id
    INNER JOIN city 
					ON address.city_id = city.city_id 
    INNER JOIN country 
					ON city.country_id = country.country_id;
                    
-- 2) All inventory details, store present, inventory id, film title, rating, rental rate and replacement cost
SELECT 
	inventory.inventory_id, inventory.store_id AS "Store Present",
    film.title, film.rental_rate, film.replacement_cost, film.rating
FROM inventory 
	INNER JOIN film ON inventory.film_id = film.film_id;
    
-- 3) Rollup question 2 into a summary of inventory by rating
SELECT 
	film.rating, count(inventory.store_id) "Total Number of Inventory",
   count(CASE WHEN inventory.store_id = 1 THEN inventory.inventory_id END) AS "Number of inventory in store 1",
   count(CASE WHEN inventory.store_id = 2 THEN inventory.inventory_id END) AS "Number of inventory in store 2",
	avg(film.rental_rate), avg(film.replacement_cost)
FROM inventory 
	INNER JOIN film ON inventory.film_id = film.film_id
GROUP BY film.rating;

-- 4) 
SELECT 
	film.rating, count(inventory.store_id) " Number of Inventory", inventory.store_id as Store,
	AVG(film.rental_rate) AS "Average Rental Rate", avg(film.replacement_cost) AS "Average Replacement Cost", 
    SUM(film.replacement_cost) AS "Total Replacement Cost", 
    SUM(film.replacement_cost)/(AVG(film.rental_rate)* count(inventory.store_id)) AS "Numer of time to break even"
FROM inventory 
	INNER JOIN film ON inventory.film_id = film.film_id
GROUP BY film.rating, 
		inventory.store_id
ORDER BY inventory.store_id
;

-- 5) List of Customers, the store they visit and their full addresses and active status
select * from payment;
SELECT 
	customer.first_name, customer.last_name, email,
    customer.store_id AS "Store Registered", 
    CASE WHEN customer.active = "1" THEN "Active customer"
		WHEN customer.active = "0" THEN "Inactive customer" END AS "Status",
    address.address, city.city, address.district, country.country
FROM customer INNER JOIN address 
				ON customer.address_id = address.address_id
			INNER JOIN city ON address.city_id = city.city_id
			INNER JOIN country ON city.country_id = country.country_id
                ;
-- 6) How much are customer spending with you. List customer name and total lifetime rentals and total payment. order by total lifetime

SELECT 
	customer.first_name, customer.last_name,
    count(payment.rental_id) AS"Lifetime transactions", sum(payment.amount) AS"Lifetime revenue"
FROM customer INNER JOIN payment 
				ON customer.customer_id = payment.customer_id
	GROUP BY customer.customer_id
    ORDER BY sum(payment.amount) DESC;
    
-- 7) List of of advisors and incestors on one table, include the company they work with

SELECT
	first_name, last_name, "Investor" AS "Role", company_name
FROM investor
UNION 
SELECT 
	first_name, last_name, "Advisor" AS "Role",
    CASE WHEN is_chairmain = 1 THEN "Chairman" ELSE "Member" END
FROM advisor
; 

-- 8) How much of our films have actors with awards. Actors with the 3 types of award, what % of these actors do we have a film. 
-- Same with 2 award and 1 award.

SELECT
	3_award_actor/count(DISTINCT film_actor.actor_id)*100 AS "Percent of actors  with 3 awards with films in Inventory",
    2_award_actor/count(DISTINCT film_actor.actor_id)*100 AS "Percent of actors  with 2 awards with films in Inventory",
    1_award_actor/count(DISTINCT film_actor.actor_id)*100 AS "Percent of actors  with 1 awards with films in Inventory"
    
    FROM
( SELECT 
	-- actor_award.actor_id, actor_award.first_name, actor_award.last_name,
    COUNT(CASE WHEN actor_award.awards = "Emmy, Oscar, Tony " THEN  1 END )AS "3_award_actor",
		COUNT(CASE WHEN actor_award.awards = "Emmy, Oscar" OR "Emmy, Tony" OR "Oscar, Tony" THEN 1 END) AS"2_award_actor",
       COUNT(CASE WHEN actor_award.awards = "Emmy" OR "Oscar" OR "Tony" THEN 1 END) AS "1_award_actor"
FROM actor_award 
)actor_grouping
	INNER JOIN film_actor;
    
SELECT 
	-- actor_award.actor_id, actor_award.first_name, actor_award.last_name,
    CASE WHEN actor_award.awards = "Emmy, Oscar, Tony " THEN  "3_award_actor"
		WHEN actor_award.awards = "Emmy, Oscar" OR "Emmy, Tony" OR "Oscar, Tony" then "2_award_actor"
		WHEN actor_award.awards = "Emmy" OR "Oscar" OR "Tony" THEN "1_award_actor"
        END AS "actor_grouping",
count(CASE WHEN actor_id IS NOT NULL THEN 1 END)/count(actor_id)
FROM actor_award 


GROUP BY actor_grouping