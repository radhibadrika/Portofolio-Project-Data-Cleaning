
SELECT *
FROM [PORTOFOLIO PROJECT].dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

SELECT *
FROM [PORTOFOLIO PROJECT].dbo.CovidVaccinations
ORDER BY 3,4



SELECT location, date, total_cases, total_deaths, population
FROM [PORTOFOLIO PROJECT].dbo.CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths (How many death per cases)
-- Shows the highest Total Deaths per Total Cases in Indonesia with an additional DeathPercentage
SELECT location, date, total_cases, CAST(total_deaths as int) as totaldeaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [PORTOFOLIO PROJECT].dbo.CovidDeaths
WHERE location like '%Indonesia'
Order BY totaldeaths DESC


--Looking at Total Cases vs Population 
--Show what percentage got covid

SELECT location, date, population,CAST (total_cases as int) as TotalCases
,(total_cases/population)*100 as CasePercentageperPopulation
FROM [PORTOFOLIO PROJECT].dbo.CovidDeaths
WHERE continent like '%Asia%'
Order BY CasePercentageperPopulation DESC



-- What country have the highest infection rate compared to the population
SELECT location, population, MAX(Total_cases) as HighestInfectionRate
,MAX(total_cases/population)*100 as CasePercentageperPopulation
FROM [PORTOFOLIO PROJECT].dbo.CovidDeaths
GROUP BY population, location
Order BY CasePercentageperPopulation desc


--Showing the country with highest deathcount per population

SELECT location, population, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [PORTOFOLIO PROJECT].dbo.CovidDeaths
WHERE continent is not null
GROUP BY population, location
Order BY Totaldeathcount desc


--Break Things Down by Continent
--Showing Continent with the highest deathcount

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [PORTOFOLIO PROJECT].dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY continent
Order BY Totaldeathcount DeSC



--Highest location deathcount in asia 
-- INDIA has the highest total death count per 2022

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [PORTOFOLIO PROJECT].dbo.CovidDeaths
WHERE continent like '%Asia%'
GROUP BY location
Order BY Totaldeathcount DeSC


--Global Numbers
-- Moreover 2 percent death across the world from Covid (2022)

SELECT SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, 
SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM [PORTOFOLIO PROJECT].dbo.CovidDeaths
WHERE continent is NOT NULL 
Order by 1,2



-- Join covid deaths and covid vaccinations data
-- Finding total population vs Vaccinations

SELECT DEA.continent,DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(CAST(VAC.new_Vaccinations as int)) 
OVER (PARTITION BY DEA.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM [PORTOFOLIO PROJECT].dbo.CovidDeaths as DEA
JOIN [PORTOFOLIO PROJECT].dbo.CovidVaccinations as VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null
ORDER BY 2,3


-- Creating CTE Table for Populations vs Vaccinations

WITH  PopvsVac (Continent, location,date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT DEA.continent,DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(CAST(VAC.new_Vaccinations as int)) 
OVER (PARTITION BY DEA.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM [PORTOFOLIO PROJECT].dbo.CovidDeaths as DEA
JOIN [PORTOFOLIO PROJECT].dbo.CovidVaccinations as VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null 
)

Select*, (RollingPeopleVaccinated / population)*100
from PopvsVac



-- Temp Table 

Create Table #PercentPopulationVaccinated
(Continent nvarchar (255), location Nvarchar (255), Date datetime, population numeric, New_vaccinations numeric
, RollingPeopleVaccinated numeric)

Insert Into #PercentPopulationVaccinated
SELECT DEA.continent,DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(CAST(VAC.new_Vaccinations as int)) 
OVER (PARTITION BY DEA.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM [PORTOFOLIO PROJECT].dbo.CovidDeaths as DEA
JOIN [PORTOFOLIO PROJECT].dbo.CovidVaccinations as VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated / population)*100
FROM #PercentPopulationVaccinated
WHERE Continent is not Null




-- Creating View To Store Data Visualization 

Create View PercentPopulationVaccinated as 
SELECT DEA.continent,DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(CAST(VAC.new_Vaccinations as int)) 
OVER (PARTITION BY DEA.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM [PORTOFOLIO PROJECT].dbo.CovidDeaths as DEA
JOIN [PORTOFOLIO PROJECT].dbo.CovidVaccinations as VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null 


GO
CREATE VIEW TotalDeathCountAsia
AS
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [PORTOFOLIO PROJECT].dbo.CovidDeaths
WHERE continent like '%Asia%'
Group by location
GO

GO

Create View TotalDeathCountPerContinent AS 

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [PORTOFOLIO PROJECT].dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY continent


GO

	
	
	





