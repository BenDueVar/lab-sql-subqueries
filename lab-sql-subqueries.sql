USE sakila;
#Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT * FROM inventory;
SELECT * FROM film;
SELECT COUNT(*) AS copy_check
FROM inventory
WHERE film_id = (SELECT film_id FROM film WHERE title = 'Hunchback Impossible');

#List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT AVG(length) FROM film;

SELECT title, length FROM film
WHERE length > (SELECT AVG(length) FROM film);

#Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT actor.first_name, actor.last_name
FROM actor WHERE actor_id IN(
	SELECT actor_id FROM film_actor WHERE film_id=(
		SELECT film_id FROM film WHERE film.title = 'Alone Trip'));
        
#JOIN REFERENCE
#SELECT actor.first_name, actor.last_name
#FROM actor
#JOIN film_actor USING(actor_id)
#JOIN film USING(film_id)
#WHERE film.title = 'Alone Trip';

#Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.

SELECT title
FROM film
WHERE film_id IN (
	SELECT film_id FROM film_category WHERE category_id = (
		SELECT category_id FROM category WHERE name = 'Family'));

#Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and 
#their primary and foreign keys.
SELECT CONCAT(first_name,' ', last_name) AS name, email
FROM customer
WHERE address_id IN 
	(SELECT address_id FROM address WHERE city_id IN 
		(SELECT city_id FROM city WHERE country_id = 
			(SELECT country_id FROM country WHERE country = 'Canada')));

# Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor 
#who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find 
#the different films that he or she starred in.

#Step1 find the most prolific
#SELECT actor_id, COUNT(*) AS film_count
#FROM film_actor
#GROUP BY actor_id
#ORDER BY film_count DESC
#LIMIT 1;

#step2 create a temporay table
CREATE TEMPORARY TABLE most_prolific_actor AS(
SELECT actor_id, COUNT(*) AS film_count
FROM film_actor
GROUP BY actor_id
ORDER BY film_count DESC
LIMIT 1);

#step3 show the titles
SELECT title
FROM film
WHERE film_id IN (SELECT film_id FROM film_actor WHERE actor_id IN (SELECT actor_id FROM most_prolific_actor)); 

#Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer
#, i.e., the customer who has made the largest sum of payments.
CREATE TEMPORARY TABLE biggest_payer AS(
SELECT customer_id, SUM(amount) AS payment_tot
FROM payment
GROUP BY customer_id
ORDER BY amount DESC
LIMIT 1);

SELECT title FROM film
WHERE film_id IN (SELECT film_id FROM inventory 
	WHERE inventory_id IN (SELECT inventory_id FROM rental
		WHERE customer_id IN (SELECT customer_id FROM biggest_payer)));

#Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. 
#You can use subqueries to accomplish this.
SELECT AVG(amount) AS average_spent
FROM payment;
SELECT customer_id, SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING total_amount_spent > (SELECT AVG(amount)FROM payment);
