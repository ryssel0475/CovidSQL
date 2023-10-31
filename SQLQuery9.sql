SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

--SELECT Location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..CovidDeaths
--ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- Likelihood of dying if contracting covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentages
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Taiwan'
ORDER BY 1, 2


--Looking at Total Cases vs Population
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Taiwan'
ORDER BY 1, 2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Group by Location, population
ORDER BY 4 DESC


--Showing Countries with Highest Dateh Count Per Population
SELECT Location,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
Order BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continents with highest death count per population
SELECT Location,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY Location
Order BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
Order BY 1,2

--Looking at Total Population vs Total Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and dea.location = 'Germany'
ORDER BY 2, 3


--USING CTE
WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/Population) *100 
FROM PopvsVac


--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population) *100
FROM #PercentPopulationVaccinated

--Creating View to stroe data for later visualization
Create View PercentPopulationVaccinated as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)


SELECT *
FROM PercentPopulationVaccinated