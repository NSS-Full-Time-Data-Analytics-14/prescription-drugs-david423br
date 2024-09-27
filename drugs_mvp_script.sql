-- 1.	a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

-- SELECT
-- 	npi,
-- 	SUM(total_claim_count) AS sum_claim_count
-- FROM prescription
-- GROUP BY npi
-- ORDER BY sum_claim_count DESC;

-- 1a ANSWER: NPI: 1881634483

--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

-- SELECT
-- 	nppes_provider_first_name,
-- 	nppes_provider_last_org_name,
-- 	specialty_description,
-- 	SUM(total_claim_count) AS sum_claim_count
-- FROM prescription
-- 	INNER JOIN prescriber
-- 		USING(npi)
-- GROUP BY 
-- 	nppes_provider_first_name,
-- 	nppes_provider_last_org_name,
-- 	specialty_description
-- ORDER BY sum_claim_count DESC;

-- 1b ANSWER: Bruce Pendley - Family Practice - 99707

-- 2.	a. Which specialty had the most total number of claims (totaled over all drugs)?

-- SELECT
-- 	specialty_description,
-- 	SUM(total_claim_count) AS sum_claim_count
-- FROM prescription
-- 	INNER JOIN prescriber
-- 		USING(npi)
-- GROUP BY 
-- 	specialty_description
-- ORDER BY sum_claim_count DESC;

-- 2a ANSWER: Family Practice - 9752347

--     b. Which specialty had the most total number of claims for opioids?

-- SELECT
-- 	specialty_description,
-- 	SUM(total_claim_count) AS sum_claim_count
-- FROM prescription
-- 	INNER JOIN prescriber
-- 		USING(npi)
-- 	INNER JOIN drug
-- 		USING(drug_name)
-- WHERE opioid_drug_flag = 'Y'
-- GROUP BY 
-- 	specialty_description
-- ORDER BY sum_claim_count DESC;

-- 2b ANSWER: Nurse Practitioner - 900845

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

-- (SELECT DISTINCT specialty_description
-- FROM prescriber)
-- EXCEPT
-- (SELECT DISTINCT specialty_description
-- FROM prescription
-- 	INNER JOIN prescriber
-- 		USING(npi));

-- 2c ANSWER: 15 specialties did not have any associated perscriptions in the perscription table.

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?



-- 3.	a. Which drug (generic_name) had the highest total drug cost?

-- SELECT 
-- 	generic_name,
-- 	SUM(total_drug_cost) AS sum_total_drug_cost
-- FROM prescription
-- INNER JOIN drug
-- 	USING(drug_name)
-- GROUP BY generic_name
-- ORDER BY sum_total_drug_cost DESC
-- LIMIT 1;

-- 3a ANSWER: "INSULIN GLARGINE,HUM.REC.ANLOG" with $104264066.35

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

-- SELECT 
-- 	generic_name,
-- 	ROUND(SUM(total_drug_cost) / SUM(total_day_supply),2) AS total_cost_per_day
-- FROM prescription
-- INNER JOIN drug
-- 	USING(drug_name)
-- GROUP BY generic_name
-- ORDER BY total_cost_per_day DESC
-- LIMIT 1;

-- 3b ANSWER: "C1 ESTERASE INHIBITOR" with $3495.22 total cost per day.

-- 4.	a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/

-- SELECT
-- 	drug_name,
-- 	CASE	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
--  			WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
-- 			ELSE 'neither' END AS drug_type
-- FROM drug;

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

-- SELECT
-- 	drug_type,
-- 	SUM(total_drug_cost::MONEY) AS total_cost
-- FROM
-- 	(SELECT
-- 		drug_name,
-- 		CASE	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
--  				WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
-- 				ELSE 'neither' END AS drug_type
-- 	FROM drug) AS drug_type_by_name
-- INNER JOIN prescription
-- 	USING (drug_name)
-- WHERE drug_type IN ('opioid', 'antibiotic')
-- GROUP BY drug_type
-- ORDER BY total_cost DESC;

-- 4b ANSWER: Opioid = $105,080,626.37, Antibiotic = $38,435,121.26

-- 5.	a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

-- SELECT
-- 	COUNT(cbsa) AS tn_cbsa_count
-- FROM cbsa
-- WHERE cbsaname LIKE '%TN';

-- 5a ANSWER: TN has 33 CBSAs

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

-- SELECT
-- 	cbsaname,
-- 	SUM(population) AS sum_pop
-- FROM cbsa
-- INNER JOIN population
-- 	USING (fipscounty)
-- GROUP BY cbsaname
-- ORDER BY sum_pop;

-- 5b ANSWER: Largest combined pop is Nashville-Davidson-Murfreesboro-Franklin, TN with 1830410. Smallest combined pop is Morristown, TN with 116352,

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

-- (SELECT
-- 	county,
-- 	SUM(population) AS sum_pop
-- FROM fips_county
-- INNER JOIN population
-- 	USING(fipscounty)
-- GROUP BY county)
-- EXCEPT
-- (SELECT
-- 	county,
-- 	SUM(population) AS sum_pop
-- FROM fips_county
-- INNER JOIN population
-- 	USING(fipscounty)
-- INNER JOIN cbsa
-- 	USING(fipscounty)
-- GROUP BY county)
-- ORDER BY sum_pop DESC
-- LIMIT 1;

-- 5c ANSWER: "SEVIER" with 95523

-- 6.	a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

-- [WRONG]
-- SELECT
-- 	drug_name,
-- 	sum_claim_count
-- FROM 
-- 	(SELECT
-- 		drug_name,
-- 		SUM(total_claim_count) AS sum_claim_count
-- 	FROM prescription
-- 	GROUP BY drug_name)
-- WHERE sum_claim_count >= 3000
-- ORDER BY sum_claim_count DESC;

-- SELECT
-- 	drug_name,
-- 	total_claim_count
-- FROM prescription
-- WHERE total_claim_count >= 3000;

-- 6a ANSWER: Returned 507 rows.

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

-- SELECT
-- 	drug_name,
-- 	total_claim_count,
-- 	opioid_drug_flag AS is_opioid
-- FROM prescription
-- INNER JOIN drug
-- 	USING(drug_name)
-- WHERE total_claim_count >= 3000;

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

-- SELECT
-- 	nppes_provider_first_name,
-- 	nppes_provider_last_org_name,
-- 	drug_name,
-- 	total_claim_count,
-- 	opioid_drug_flag AS is_opioid
-- FROM prescription
-- INNER JOIN drug
-- 	USING(drug_name)
-- INNER JOIN prescriber
-- 	USING(npi)
-- WHERE total_claim_count >= 3000;


-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

-- SELECT
-- 	npi,
-- 	drug_name
-- FROM prescriber
-- CROSS JOIN drug
-- WHERE specialty_description = 'Pain Management'
-- AND nppes_provider_city = 'NASHVILLE'
-- AND opioid_drug_flag = 'Y';


--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

-- SELECT
-- 	prescriber.npi,
-- 	drug.drug_name,
-- 	total_claim_count
-- FROM prescriber
-- CROSS JOIN drug
-- FULL JOIN prescription
-- 	ON prescriber.npi = prescription.npi
-- 	AND drug.drug_name = prescription.drug_name
-- WHERE specialty_description = 'Pain Management'
-- 	AND nppes_provider_city = 'NASHVILLE'
-- 	AND opioid_drug_flag = 'Y';


--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

-- SELECT
-- 	prescriber.npi,
-- 	drug.drug_name,
-- 	COALESCE(total_claim_count,0)
-- FROM drug
-- CROSS JOIN prescriber
-- FULL JOIN prescription
-- 	ON prescriber.npi = prescription.npi
-- 	AND drug.drug_name = prescription.drug_name
-- WHERE specialty_description = 'Pain Management'
-- 	AND nppes_provider_city = 'NASHVILLE'
-- 	AND opioid_drug_flag = 'Y';
