-- 1. How many npi numbers appear in the prescriber table but not in the prescription table?

WITH not_in_prescription AS	((SELECT
								npi
							FROM prescriber)
							EXCEPT
							(SELECT
								npi
							FROM prescription))
SELECT COUNT(npi) AS npi_count_not_in_prescription
FROM not_in_prescription;

1 ANSWER: 4458

-- 2.	a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.

SELECT
	generic_name
FROM drug
INNER JOIN prescription
	USING(drug_name)
INNER JOIN prescriber
	USING(npi)
WHERE specialty_description = 'Family Practice'
GROUP BY generic_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

--	    b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.

SELECT
	generic_name
FROM drug
INNER JOIN prescription
	USING(drug_name)
INNER JOIN prescriber
	USING(npi)
WHERE specialty_description = 'Cardiology'
GROUP BY generic_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

--  	c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question.

-- (SELECT
-- 	generic_name
-- 	SUM(total_claim_count) AS sum_claim_count,
-- 	specialty_description
-- FROM drug
-- INNER JOIN prescription
-- 	USING(drug_name)
-- INNER JOIN prescriber
-- 	USING(npi)
-- WHERE specialty_description = 'Family Practice'
-- GROUP BY specialty_description, generic_name
-- ORDER BY sum_claim_count DESC
-- LIMIT 5)
-- INTERSECT
-- (SELECT
-- 	generic_name
-- 	SUM(total_claim_count) AS sum_claim_count,
-- 	specialty_description
-- FROM drug
-- INNER JOIN prescription
-- 	USING(drug_name)
-- INNER JOIN prescriber
-- 	USING(npi)
-- WHERE specialty_description = 'Cardiology'
-- GROUP BY specialty_description, generic_name
-- ORDER BY sum_claim_count DESC
-- LIMIT 5)
-- ORDER BY generic_name;

(SELECT
	generic_name
FROM drug
INNER JOIN prescription
	USING(drug_name)
INNER JOIN prescriber
	USING(npi)
WHERE specialty_description = 'Family Practice'
GROUP BY specialty_description, generic_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5)
INTERSECT
(SELECT
	generic_name
FROM drug
INNER JOIN prescription
	USING(drug_name)
INNER JOIN prescriber
	USING(npi)
WHERE specialty_description = 'Cardiology'
GROUP BY specialty_description, generic_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5);

-- 3. Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
--     	a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. Report the npi, the total number of claims, and include a column showing the city.

SELECT
	npi,
	SUM(total_claim_count) AS sum_claim_count,
	nppes_provider_city
FROM prescription
INNER JOIN prescriber
	USING(npi)
WHERE nppes_provider_city = 'NASHVILLE'
GROUP BY npi, nppes_provider_city
ORDER BY sum_claim_count DESC
LIMIT 5;
    
--     	b. Now, report the same for Memphis.

SELECT
	npi,
	SUM(total_claim_count) AS sum_claim_count,
	nppes_provider_city
FROM prescription
INNER JOIN prescriber
	USING(npi)
WHERE nppes_provider_city = 'MEMPHIS'
GROUP BY npi, nppes_provider_city
ORDER BY sum_claim_count DESC
LIMIT 5;
    
--     	c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.

(SELECT
	npi,
	SUM(total_claim_count) AS sum_claim_count,
	nppes_provider_city
FROM prescription
INNER JOIN prescriber
	USING(npi)
WHERE nppes_provider_city = 'NASHVILLE'
GROUP BY npi, nppes_provider_city
ORDER BY sum_claim_count DESC
LIMIT 5)
UNION
(SELECT
	npi,
	SUM(total_claim_count) AS sum_claim_count,
	nppes_provider_city
FROM prescription
INNER JOIN prescriber
	USING(npi)
WHERE nppes_provider_city = 'MEMPHIS'
GROUP BY npi, nppes_provider_city
ORDER BY sum_claim_count DESC
LIMIT 5)
UNION
(SELECT
	npi,
	SUM(total_claim_count) AS sum_claim_count,
	nppes_provider_city
FROM prescription
INNER JOIN prescriber
	USING(npi)
WHERE nppes_provider_city = 'KNOXVILLE'
GROUP BY npi, nppes_provider_city
ORDER BY sum_claim_count DESC
LIMIT 5)
UNION
(SELECT
	npi,
	SUM(total_claim_count) AS sum_claim_count,
	nppes_provider_city
FROM prescription
INNER JOIN prescriber
	USING(npi)
WHERE nppes_provider_city = 'CHATTANOOGA'
GROUP BY npi, nppes_provider_city
ORDER BY sum_claim_count DESC
LIMIT 5)
ORDER BY nppes_provider_city;

-- 4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.

-- WITH sum_od_t AS	(SELECT
-- 						county,
-- 						SUM(overdose_deaths) AS sum_od_deaths
-- 					FROM overdose_deaths AS odd
-- 					INNER JOIN fips_county AS fc
-- 						ON odd.fipscounty = fc.fipscounty::INT
-- 					GROUP BY county),
-- avg_od_t AS			(SELECT
-- 						AVG(overdose_deaths) AS avg_od_deaths
-- 					FROM overdose_deaths AS odd)
-- SELECT
-- 	DISTINCT county,
-- 	sum_od_deaths
-- FROM sum_od_t
-- CROSS JOIN avg_od_t
-- WHERE sum_od_deaths > avg_od_deaths
-- ORDER BY sum_od_deaths DESC;

WITH sum_od_t AS	(SELECT
						county,
						SUM(overdose_deaths) AS sum_od_deaths
					FROM overdose_deaths AS odd
					INNER JOIN fips_county AS fc
						ON odd.fipscounty = fc.fipscounty::INT
					GROUP BY county)
SELECT
	DISTINCT county,
	sum_od_deaths
FROM sum_od_t
WHERE sum_od_deaths > (SELECT AVG(sum_od_deaths) FROM sum_od_t)
ORDER BY sum_od_deaths DESC;

-- 4 ANSWER: Average OD Deaths 12.6052631578947368. Top County Davidson with 689 OD Deaths.

-- 5.	a. Write a query that finds the total population of Tennessee.

SELECT
	SUM(population) AS tn_pop
FROM population
INNER JOIN fips_county
	USING(fipscounty)
WHERE state = 'TN';

--     	b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is contained in that county.

WITH tn_pop_table AS	(SELECT
							SUM(population) AS tn_pop
						FROM population
						INNER JOIN fips_county
							USING(fipscounty)
						WHERE state = 'TN')
SELECT
	county,
	population,
	ROUND((100 * population / tn_pop),2) AS percent_of_tn_pop
FROM tn_pop_table
CROSS JOIN fips_county
INNER JOIN population
	USING(fipscounty)
ORDER BY percent_of_tn_pop DESC;

