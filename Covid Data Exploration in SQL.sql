
USE Project_Data;

SELECT *
FROM CovidVaccinations$
ORDER BY 3,4;

SELECT *
FROM CovidDeaths$
ORDER BY 3,4;

-- the probability of dying in United States for a covid infected person
SELECT Location, date, total_cases, new_cases, total_deaths, population,(total_deaths/total_cases) *100 AS deathpercent
FROM CovidDeaths$
WHERE Location = 'United States'
ORDER BY 2;

-- total cases by population
-- percentage of population infected
SELECT Location, date, total_cases, new_cases, total_deaths, population,(total_cases/population) *100 AS casespercentage
FROM CovidDeaths$
WHERE Location = 'United States'
ORDER BY 2;

-- countries with highest infection rate compared to population
SELECT Location,MAX( total_cases) AS peak_cases, population,MAX(total_cases/population) *100 AS peak_cases_percentage
FROM CovidDeaths$
GROUP BY Location, population
ORDER BY 4 DESC; 

-- countries with highest deeath  rate compared to population
SELECT Location,MAX( total_deaths) AS peak_deaths, population,MAX(total_deaths/population) *100 AS peak_death_percentage
FROM CovidDeaths$
GROUP BY Location, population
ORDER BY 4 DESC; 

-- highest deaths by countries 
SELECT Location, MAX(cast(total_deaths AS INT)) AS peak_deaths
FROM CovidDeaths$
WHERE continent is not null
GROUP BY Location
ORDER BY 2 DESC;

-- highest deaths by continent 
SELECT continent, MAX(cast(total_deaths AS INT)) AS peak_deaths
FROM CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC;

-- world cases and deaths
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths
FROM CovidDeaths$
WHERE continent is not null;

-- Join the tables
SELECT *
FROM CovidDeaths$ dt
JOIN CovidVaccinations$ vc 
	ON dt.Location = vc.location
	AND dt.date = vc.date

-- rolling vaccinations 
SELECT dt.continent, dt.Location, dt.date, dt.population,vc.new_vaccinations, 
SUM(CAST(vc.new_vaccinations AS INT)) OVER (PARTITION BY dt.Location ORDER BY dt.Location,dt.date) AS RollingVaccinations
FROM CovidDeaths$ dt
JOIN CovidVaccinations$ vc 
	ON dt.location = vc.location
	AND dt.date = vc.date
WHERE dt.continent is not null
ORDER BY 2,3

-- vacinated percentage using rolling vaccination column
WITH VacPopn (Continent, Location, Date, Population, New_vaccinations,RollingPeopleVaccinated)
AS 
(
SELECT dt.continent, dt.Location, dt.date, dt.population,vc.new_vaccinations, 
SUM(CAST(vc.new_vaccinations AS INT)) OVER (PARTITION BY dt.Location ORDER BY dt.Location,dt.date) AS RollingVaccinations
FROM CovidDeaths$ dt
JOIN CovidVaccinations$ vc 
	ON dt.location = vc.location
	AND dt.date = vc.date
WHERE dt.continent is not null
)

SELECT *, (RollingPeopleVaccinated/Population) *100
FROM VacPopn;

-- Create views for vizualizations
CREATE VIEW PopulationVaccinated AS
SELECT dt.continent, dt.Location, dt.date, dt.population,vc.new_vaccinations, 
SUM(CAST(vc.new_vaccinations AS INT)) OVER (PARTITION BY dt.Location ORDER BY dt.Location,dt.date) AS RollingVaccinations
FROM CovidDeaths$ dt
JOIN CovidVaccinations$ vc 
	ON dt.location = vc.location
	AND dt.date = vc.date
WHERE dt.continent is not null;

SELECT *
FROM PopulationVaccinated;
