Select*
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Select*
--from PortfolioProject..CovidVaccination$
--order by 3,4

--Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Looking at Total Cases vs Population
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Looking at Countries with Highest Infectin Rate compared to Population
Select Location, MAX(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
where continent is not null
Group by Location, Population
order by PercentagePopulationInfected desc

--Looking at Countries with Highest Infectin Rate compared to Population over time
Select Location, date, MAX(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
where continent is not null
Group by Location, Population, date
order by PercentagePopulationInfected desc

--Showing Countries with Highest Death count per Continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is null
and location not in ('world', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


--Showing contintents with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
Group by Location
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as NewDeathVNewCases
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2



--Lookint at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentofPeople
from PopvsVac


--Temp Table

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as PercentofPeople
from #PercentPopulationVaccinated




