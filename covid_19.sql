CREATE DATABASE `Portfolio_Project`;

USE `Portfolio_Project`;

SELECT *
FROM Portfolio_Project.CovidDeaths
WHERE continent is not null
order by 3,4;


SELECT *
FROM Portfolio_Project.CovidVaccinations
WHERE continent is not null
order by 3,4;


-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_project.coviddeaths
WHERE continent is not null
ORDER BY 1,2;


-- Looking at Toatal Cases VS Total Deaths
-- show likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM portfolio_project.coviddeaths
WHERE continent is not null
ORDER BY 1,2;


SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM portfolio_project.coviddeaths
WHERE Location like '%states%'
and continent is not null
ORDER BY 1,2;


-- Looking at Total Cases VS Population
-- Shows what percentage of population got Covid
SELECT Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
FROM portfolio_project.coviddeaths
WHERE Location like '%states%'
and continent is not null
ORDER BY 1,2;


-- Looking at Countries with  Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM portfolio_project.coviddeaths
-- WHERE Location like '%states%'
WHERE continent is not null
GROUP BY Location,Population
ORDER BY PercentPopulationInfected desc;


-- Showing Countries with Highest Death Count Per Population
-- UNSIGNED or SIGNED this means will converted to integer datatype
SELECT Location,  MAX(cast(total_deaths as UNSIGNED)) AS TotalDeathCount
FROM portfolio_project.coviddeaths
-- WHERE Location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc;


-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT Location,  MAX(cast(total_deaths as UNSIGNED)) AS TotalDeathCount
FROM portfolio_project.coviddeaths
-- WHERE Location like '%states%'
WHERE continent is   null
GROUP BY Location
ORDER BY TotalDeathCount desc; 


SELECT continent,  MAX(cast(total_deaths as UNSIGNED)) AS TotalDeathCount
FROM portfolio_project.coviddeaths
-- WHERE Location like '%states%'
WHERE continent is  not null
GROUP BY continent
ORDER BY TotalDeathCount desc;


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continent with Highest Death Count Per Population
SELECT continent,  MAX(cast(total_deaths as UNSIGNED)) AS TotalDeathCount
FROM portfolio_project.coviddeaths
-- WHERE Location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc ;

-- GLOBAL NUMBERS
SELECT  date, SUM(new_cases) as total_cases,SUM(CAST(new_deaths as signed)) as total_deaths, SUM(CAST(new_deaths as signed))/SUM(new_cases)*100 as DeathPercentage -- , total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM portfolio_project.coviddeaths
-- WHERE Location like '%states%'
WHERE continent is not null
group by date
ORDER BY 1,2;

SELECT   SUM(new_cases) as total_cases,SUM(CAST(new_deaths as signed)) as total_deaths, SUM(CAST(new_deaths as signed))/SUM(new_cases)*100 as DeathPercentage -- , total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM portfolio_project.coviddeaths
-- WHERE Location like '%states%'
WHERE continent is not null
-- group by date
ORDER BY 1,2;


-- Now WE work on Covid Vaccinations
SELECT *
FROM portfolio_project.coviddeaths dea
JOIN portfolio_project.covidvaccinations vac
ON dea.location = vac.location
and dea.date = vac.date;


-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
FROM portfolio_project.coviddeaths dea
JOIN portfolio_project.covidvaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;



SELECT dea.continent, dea.location, dea.date, dea.population
,vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations AS SIGNED)) over (partition by dea.location order by dea.location, date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM portfolio_project.coviddeaths dea
JOIN portfolio_project.covidvaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;


SELECT dea.continent, dea.location, dea.date, dea.population
,vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations AS SIGNED)) over (partition by dea.location order by dea.location, date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM portfolio_project.coviddeaths dea
JOIN portfolio_project.covidvaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;


-- USE CTE 
With PopvsVac (Continent, Location ,Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population
,vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations AS SIGNED)) over (partition by dea.location order by dea.location, date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM portfolio_project.coviddeaths dea
JOIN portfolio_project.covidvaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 1,2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 As RollingPercentage
FROM PopvsVac;



-- TEMP TABLE
DROP TABLE IF exists PercentPopulationVaccinated;
CREATE TEMPORARY  TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population
,vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations AS SIGNED)) over (partition by dea.location order by dea.location, date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM portfolio_project.coviddeaths dea
JOIN portfolio_project.covidvaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;
-- order by 1,2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 As RollingPercentage
FROM PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population
,vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations AS SIGNED)) over (partition by dea.location order by dea.location, date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM portfolio_project.coviddeaths dea
JOIN portfolio_project.covidvaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;
-- order by 1,2,3;


select * 
from PercentPopulationVaccinated;