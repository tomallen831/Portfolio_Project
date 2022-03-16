/*
Object: Utilize SQL to clean dataset prior to using Tableau 
Author: Thomas Allen
Description: Using COVID-19 data this project deomonstrates
	some SQL queries with the intent of being used in visualizations
*/

SELECT * 
FROM PortfolioProject..Sheet1$
WHERE continent is not null
order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Sheet1$
ORDER BY 1, 2



-- Total Cases vs Total Deaths
-- Use case of where location
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Sheet1$
WHERE location like '%states%'
ORDER BY 1, 2

-- Total Cases vs Population
-- Use case of where location
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentageWCovid
From PortfolioProject..Sheet1$
WHERE location like '%states%'
ORDER BY 1, 2

-- Countries with highest infection rates compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..Sheet1$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Countries with Highest Death Count Per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..Sheet1$
--WHERE location like '%states%'
WHERE continent is null 
	AND location <> 'Low income'
	AND location <> 'High income' 
	AND location <> 'Lower middle income' 
	AND location <> 'Upper middle income'
GROUP BY location
ORDER BY TotalDeathCount desc

--Countries with Highest Death Count Per Population by Continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..Sheet1$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--Show continent with Highest Death Counts
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..Sheet1$
--WHERE location like '%states%'
WHERE continent is null 
	AND location <> 'Low income'
	AND location <> 'High income' 
	AND location <> 'Lower middle income' 
	AND location <> 'Upper middle income'
GROUP BY location
ORDER BY TotalDeathCount desc

-- Global Numbers
-- Total Cases vs Total Deaths
-- Use case of where location
SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..Sheet1$
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

-- Total Population vs Vaccinations
SELECT continent, location, date, population, new_vaccinations, SUM(cast(new_vaccinations as BIGINT)) OVER (Partition by location ORDER BY location, CONVERT(date, date))
as RollingPeopleVaccinated
From PortfolioProject..Sheet1$
WHERE continent is not null
	AND location <> 'Low income'
	AND location <> 'High income' 
	AND location <> 'Lower middle income' 
	AND location <> 'Upper middle income'
--GROUP BY date
ORDER BY 2, 3

-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT continent, location, date, population, new_vaccinations, SUM(cast(new_vaccinations as BIGINT)) OVER (Partition by location ORDER BY location, CONVERT(date, date))
as RollingPeopleVaccinated
From PortfolioProject..Sheet1$
WHERE continent is not null
	AND location <> 'Low income'
	AND location <> 'High income' 
	AND location <> 'Lower middle income' 
	AND location <> 'Upper middle income'
--GROUP BY date
--ORDER BY 2, 3 OFFSET 0 Rows
)
SELECT *, (RollingPeopleVaccinated/population) * 100
From PopvsVac

-- Use CTE
-- Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PerccentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PerccentPopulationVaccinated
SELECT continent, location, date, population, new_vaccinations, SUM(cast(new_vaccinations as BIGINT)) OVER (Partition by location ORDER BY location, CONVERT(date, date))
as RollingPeopleVaccinated
From PortfolioProject..Sheet1$
WHERE continent is not null
	AND location <> 'Low income'
	AND location <> 'High income' 
	AND location <> 'Lower middle income' 
	AND location <> 'Upper middle income'
--GROUP BY date
--ORDER BY 2, 3 OFFSET 0 Rows

SELECT *, (RollingPeopleVaccinated/population) * 100
From #PerccentPopulationVaccinated

-- Create a view for visualizations
Create View PercentPopulationVaccinated as
SELECT continent, location, date, population, new_vaccinations, SUM(cast(new_vaccinations as BIGINT)) OVER (Partition by location ORDER BY location, CONVERT(date, date))
as RollingPeopleVaccinated
From PortfolioProject..Sheet1$
WHERE continent is not null
	AND location <> 'Low income'
	AND location <> 'High income' 
	AND location <> 'Lower middle income' 
	AND location <> 'Upper middle income'
--GROUP BY date
--ORDER BY 2, 3 OFFSET 0 Rows

Create View One as
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..Sheet1$
WHERE continent is not null
	AND location <> 'Low income'
	AND location <> 'High income' 
	AND location <> 'Lower middle income' 
	AND location <> 'Upper middle income'
ORDER By 1,2

Create View Two as 
SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..Sheet1$
WHERE continent is not null
	AND location <> 'Low income'
	AND location <> 'High income' 
	AND location <> 'Lower middle income' 
	AND location <> 'Upper middle income'
GROUP by location
ORDER by TotalDeathCount desc

Create View Three as
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
FROM PortfolioProject..Sheet1$
GROUP By location, population
ORDER By PercentPopulationInfected desc

Create View Four as
Select location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
From PortfolioProject..Sheet1$
Group by Location, Population, date
ORDER By PercentPopulationInfected desc
