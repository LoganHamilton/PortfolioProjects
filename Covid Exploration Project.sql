Select *
From [Covid Portfolio Project]..CovidDeaths
where continent is not null
Order by 3,4

-- Select Data that we are going to be using for visualization

Select Location, date, total_cases, new_cases, total_deaths, population
From [Covid Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Covid Portfolio Project]..CovidDeaths
Where location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows percentage of population that got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
From [Covid Portfolio Project]..CovidDeaths
--Where location like '%states%'
order by 1,2



-- Looking at countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Covid Portfolio Project]..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by Location,Population
order by PercentPopulationInfected desc


-- Showing Countries with highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid Portfolio Project]..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc



-- Showing continents with the highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid Portfolio Project]..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

--total global cases by date
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Covid Portfolio Project]..CovidDeaths
--Where location like '%states%'
where continent is not null
Group By date
order by 1,2


-- total global cases
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Covid Portfolio Project]..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group By date
order by 1,2



-- Problem with some locations not being locations at all (Ie.g. income levels, international, world)

-- Finding which ones to drop from the dataset
Select Distinct iso_code, continent, location 
From [Covid Portfolio Project]..CovidDeaths
where iso_code like '%OWID%' AND continent is null
-- Dropping OWID_LIC, OWID_WRL, OWID_EUN, OWID_HIC, OWID_INT, OWID_LMC, OWID_UMC

DELETE 
From [Covid Portfolio Project]..CovidDeaths
where iso_code IN ('OWID_LIC', 'OWID_WRL', 'OWID_EUN', 'OWID_HIC', 'OWID_INT', 'OWID_LMC', 'OWID_UMC')


---------------------------------------------LOOKING AT VACCINATIONS---------------------------------------------------------

Select * 
From [Covid Portfolio Project]..CovidVaccinations
where continent is not null
order by 3,4



--Selecting data I'm using

Select location, date, people_vaccinated, people_fully_vaccinated, total_vaccinations, population
From [Covid Portfolio Project]..CovidVaccinations
where continent is not null
order by 1, 2

-- Countries with the most vaccinations
Select location, MAX(cast(total_vaccinations as bigint)) as totalVaccinations
From [Covid Portfolio Project]..CovidVaccinations
where continent is not null
Group by Location
order by totalVaccinations desc


--Countries with most fully vaccinated people
Select location, MAX(cast(people_fully_vaccinated as bigint)) as FullyVaccinated
From [Covid Portfolio Project]..CovidVaccinations
where continent is not null
Group by Location
order by FullyVaccinated desc


-- Fully Vaccinated vs population
Select location, MAX(people_fully_vaccinated/population * 100) as FullyVaccinatedRate
From [Covid Portfolio Project]..CovidVaccinations
where continent is not null
Group by location
order by FullyVaccinatedRate desc




--Looking at Total Population Vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From [Covid Portfolio Project]..CovidDeaths dea
Join [Covid Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From [Covid Portfolio Project]..CovidDeaths dea
Join [Covid Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac
order by 2,3




-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From [Covid Portfolio Project]..CovidDeaths dea
Join [Covid Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated
order by 2,3



--Creating View to store data for later visualization 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From [Covid Portfolio Project]..CovidDeaths dea
Join [Covid Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * 
From PercentPopulationVaccinated
order by 2,3


