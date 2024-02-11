SELECT *
FROM PortfolioProject..COVIDDEATHS$
Where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..['COVID VACCINATIONS$']
--ORDER BY 3,4

-- Select Data that we are going to be using
-- Shows likelihood of dying if you contract covid in your country
Select Location,Date,total_cases, new_cases,total_deaths,population
FROM PortfolioProject..COVIDDEATHS$
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
Select location,date,total_cases, total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM PortfolioProject..COVIDDEATHS$
Where location like '%India%'
ORDER BY 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of Population got covid
Select location,date,total_cases,population,(cast(total_cases as float)/cast(population as float))*100 as PercentOfPopulationInfected
FROM PortfolioProject..COVIDDEATHS$
--Where location like '%India%'
ORDER BY 1,2

-- Looking at countries with Highest Infection Rate compared to Population
Select location,population,continent, MAX(total_cases)as HighestInfectionCount,MAX(cast(total_cases as float)/cast(population as float))*100 as PercentOfPopulationInfected
FROM PortfolioProject..COVIDDEATHS$
--Where location like '%India%'
GROUP BY location,population,continent
order by PercentOfPopulationInfected desc


-- Showing Countries with highest Death Count Per Population
Select location,continent, MAX(cast (total_deaths as int))as TotalDeathCount
FROM PortfolioProject..COVIDDEATHS$
--Where location like '%India%'
where continent is not null
GROUP BY location,continent
order by TotalDeathCount desc


--Let's break things up by Continent


-- Showing the Continents with the higesht death counts
Select continent, MAX(cast (total_deaths as int))as TotalDeathCount
FROM PortfolioProject..COVIDDEATHS$
--Where location like '%India%'
where continent is not null
GROUP BY continent
order by TotalDeathCount desc

-- Looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..COVIDDEATHS$ as dea
Join PortfolioProject..['COVID VACCINATIONS$'] as vac
   ON dea.location= vac.location
   and dea.date= vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
With PopvsVac ( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..COVIDDEATHS$ as dea
Join PortfolioProject..['COVID VACCINATIONS$'] as vac
   ON dea.location= vac.location
   and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE

DROP Table if exists  #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location  nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..COVIDDEATHS$ as dea
Join PortfolioProject..['COVID VACCINATIONS$'] as vac
   ON dea.location= vac.location
   and dea.date= vac.date
where dea.continent is not null
order by 2,3
SELECT *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..COVIDDEATHS$ as dea
Join PortfolioProject..['COVID VACCINATIONS$'] as vac
   ON dea.location= vac.location
   and dea.date= vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated