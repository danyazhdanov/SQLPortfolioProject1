SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--WHERE continent IS NOT NULL
--ORDER BY 3,4


--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..CovidDeaths
--WHERE continent IS NOT NULL
--ORDER BY 1,2

-- Total cases vs Total Deaths
-- Probability of dying due to covid infection in a certain country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRateInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Russia%'
	AND continent IS NOT NULL
ORDER BY 1,2

-- Total cases vs Population
-- Rates of infection in a certain country

SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Russia%'
	AND continent IS NOT NULL
ORDER BY 1,2


-- Countries with Highest Infection Rate 

SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC


-- Countries with highest Death Count compared to population

SELECT location, Population, MAX(Cast(total_deaths as int)) as HighestDeathCount, MAX(((Cast(total_deaths as int))/population)*100) as HighestDeathRatePopulation
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC


-- Continents with highest Death Count compared to population

SELECT location, Population, MAX(Cast(total_deaths as int)) as HighestDeathCount, MAX(((Cast(total_deaths as int))/population)*100) as HighestDeathRatePopulation
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND location NOT LIKE '%income%' AND location NOT LIKE '%International%' AND location NOT LIKE '%World%' AND location NOT LIKE '%Union%'
GROUP BY location, population
ORDER BY 4 DESC


--World Death Percentage From Covid Infection

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 as DeathRateInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Russia%'
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at the number of Population vs Vacciantions

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS VaccinationsRollingCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--CTE for Vaccinations Rate Rolling Count

WITH VacVsPop (Continent, Location, Date, Population, New_Vaccinations, VaccinationsRollingCount)
	AS
		(
		SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS VaccinationsRollingCount
		FROM PortfolioProject..CovidDeaths dea
		JOIN PortfolioProject..CovidVaccinations vac
			ON dea.location = vac.location
			AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL
		)
SELECT *, ((VaccinationsRollingCount)/Population)*100 AS VaccinatedPercentage
FROM VacVsPop



--Temp Table for Vaccinations Rate Rolling Count

DROP TABLE IF EXISTS #VaccinatedPercent
CREATE TABLE #VaccinatedPercent
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
VaccinationsRollingCount numeric)

INSERT INTO #VaccinatedPercent
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS VaccinationsRollingCount
		FROM PortfolioProject..CovidDeaths dea
		JOIN PortfolioProject..CovidVaccinations vac
			ON dea.location = vac.location
			AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL

SELECT *, ((VaccinationsRollingCount)/Population)*100 AS VaccinatedPercentage
FROM #VaccinatedPercent


--View for Continents data visualisation

CREATE View VaccinatedPercent AS
SELECT location, Population, MAX(Cast(total_deaths as int)) as HighestDeathCount, MAX(((Cast(total_deaths as int))/population)*100) as HighestDeathRatePopulation
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND location NOT LIKE '%income%' AND location NOT LIKE '%International%' AND location NOT LIKE '%World%' AND location NOT LIKE '%Union%'
GROUP BY location, population


SELECT *
FROM VaccinatedPercent
