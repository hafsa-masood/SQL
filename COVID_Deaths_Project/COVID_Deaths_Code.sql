-- Queries used to obtain chosen data for visualization are starred! 

-- Create table to import data from .csv file

CREATE TABLE COVID_death_vaccine (
	iso_code text,
	continent text,
	location text,
	date date,
	total_cases numeric,
	new_cases numeric,
	new_cases_smoothed numeric,
	total_deaths numeric,
	new_deaths numeric,
	new_deaths_smoothed numeric,
	total_cases_per_million numeric,
	new_cases_per_million numeric,
	new_cases_smoothed_per_million numeric,
	total_deaths_per_million numeric,
	new_deaths_per_million numeric,
	new_deaths_smoothed_per_million numeric,
	reproduction_rate numeric,
	icu_patients numeric,
	icu_patients_per_million numeric,
	hosp_patients numeric,
	hosp_patients_per_million numeric,
	weekly_icu_admissions numeric,
	weekly_icu_admissions_per_million numeric,
	weekly_hosp_admissions numeric,
	weekly_hosp_admissions_per_million numeric,
	total_tests numeric,
	new_tests numeric,
	total_tests_per_thousand numeric,
	new_tests_per_thousand numeric,
	new_tests_smoothed numeric,
	new_tests_smoothed_per_thousand numeric,
	positive_rate numeric,
	tests_per_case numeric,
	tests_units text,
	total_vaccinations numeric,
	people_vaccinated numeric,
	people_fully_vaccinated numeric,
	total_boosters numeric,
	new_vaccinations numeric,
	new_vaccinations_smoothed numeric,
	total_vaccinations_per_hundred numeric,
	people_vaccinated_per_hundred numeric,
	people_fully_vaccinated_per_hundred numeric,
	total_boosters_per_hundred numeric,
	new_vaccinations_smoothed_per_million numeric,
	new_people_vaccinated_smoothed numeric,
	new_people_vaccinated_smoothed_per_hundred numeric,
	stringency_index numeric,
	population numeric,
	population_density numeric,
	median_age numeric,
	aged_65_older numeric,
	aged_70_older numeric,
	gdp_per_capita numeric,
	extreme_poverty numeric,
	cardiovasc_death_rate numeric,
	diabetes_prevalence numeric,
	female_smokers numeric,
	male_smokers numeric,
	handwashing_facilities numeric,
	hospital_beds_per_thousand numeric,
	life_expectancy numeric,
	human_development_index numeric,
	excess_mortality_cumulative_absolute numeric,
	excess_mortality_cumulative numeric,
	excess_mortality numeric,
	excess_mortality_cumulative_per_million numeric
);

-- Create COVID deaths table from orginial table 

CREATE TABLE COVID_deaths AS
	SELECT 
		iso_code,
		continent,
		location,
		date,
		population,
		total_cases,
		new_cases,
		new_cases_smoothed,
		total_deaths,
		new_deaths,
		new_deaths_smoothed,
		total_cases_per_million,
		new_cases_per_million,
		new_cases_smoothed_per_million,
		total_deaths_per_million,
		new_deaths_per_million,
		new_deaths_smoothed_per_million,
		reproduction_rate,
		icu_patients,
		icu_patients_per_million,
		hosp_patients,
		hosp_patients_per_million,
		weekly_icu_admissions,
		weekly_icu_admissions_per_million,
		weekly_hosp_admissions,
		weekly_hosp_admissions_per_million
	FROM
		covid_death_vaccine;

-- Create COVID vaccine table from original table 

CREATE TABLE covid_vaccines AS 
	SELECT
		iso_code,
		continent,
		location,
		date,
		total_tests,
		new_tests,
		total_tests_per_thousand,
		new_tests_per_thousand,
		new_tests_smoothed,
		new_tests_smoothed_per_thousand,
		positive_rate,
		tests_per_case,
		tests_units,
		total_vaccinations,
		people_vaccinated,
		people_fully_vaccinated,
		total_boosters,new_vaccinations,
		new_vaccinations_smoothed,
		total_vaccinations_per_hundred,
		people_vaccinated_per_hundred,
		people_fully_vaccinated_per_hundred,
		total_boosters_per_hundred,
		new_vaccinations_smoothed_per_million,
		new_people_vaccinated_smoothed,
		new_people_vaccinated_smoothed_per_hundred,
		stringency_index,
		population,population_density,
		median_age,
		aged_65_older,
		aged_70_older,
		gdp_per_capita,
		extreme_poverty,
		cardiovasc_death_rate,
		diabetes_prevalence,
		female_smokers,
		male_smokers,
		handwashing_facilities,
		hospital_beds_per_thousand,
		life_expectancy,
		human_development_index,
		excess_mortality_cumulative_absolute,
		excess_mortality_cumulative,
		excess_mortality,
		excess_mortality_cumulative_per_million
	FROM
		covid_death_vaccine;

-- Look at total cases vs total deaths for each country 

SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 AS death_percentage
FROM
	covid_deaths
ORDER BY 
	1,2;

-- What percentage of population has gotten COVID for each country

SELECT 
	location, 
	date, 
	population,
	total_cases, 
	(total_cases/population)*100 AS infection_percentage
FROM
	covid_deaths
ORDER BY 
	1,2;

-- *Countries with highest infection rate compared to population*

SELECT 
	location, 
	population,
	MAX(total_cases) AS highest_infection_count,
	MAX((total_cases/population))*100 AS infection_percentage
FROM
	covid_deaths
GROUP BY 
	location, population 
ORDER BY 
	infection_percentage DESC;

-- *Countries with highest infection rate compared to population with dates* 

SELECT 
	location, 
	population,
	date,
	MAX(total_cases) AS highest_infection_count,
	MAX((total_cases/population))*100 AS infection_percentage
FROM
	covid_deaths
GROUP BY 
	location, population, date 
ORDER BY 
	infection_percentage DESC;

-- Countries with highest death count per population 

SELECT
	location, 
	MAX(cast(Total_deaths as int)) as total_death_count
FROM
	covid_deaths 
WHERE 
	continent IS NOT NULL 
GROUP BY 
	location 
ORDER BY total_death_count DESC;

-- *Death count by continent* 

SELECT
	location, 
	SUM(cast(Total_deaths as int)) as total_death_count
FROM
	covid_deaths 
WHERE 
	continent IS NULL
	AND
	location IN ('Africa','Asia','Europe','North America','South America','Oceania')
GROUP BY 
	location 
ORDER BY total_death_count DESC;

-- *Global Numbers*

SELECT
	SUM(new_cases) AS total_new_cases,
	SUM(new_deaths) AS total_new_deaths,
	SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM
	covid_deaths 
WHERE
	continent IS NOT NULL 
ORDER BY 
	1,2

-- Percentage of population vaccinated

CREATE TEMP TABLE percent_population_vaccinated AS 
SELECT
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM 
	covid_deaths dea
JOIN
	covid_vaccines vac
ON 
	dea.location = vac.location
	AND
	dea.date = vac.date
WHERE
	dea.continent IS NOT NULL

SELECT *, (rolling_people_vaccinated/population)*100
FROM percent_population_vaccinated
