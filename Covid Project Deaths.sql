Select *
From [Covid Portfolio Project]..CovidDeaths
where continent is not null
Order by 3,4

--Select *
--From [Covid Portfolio Project]..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using

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



-- Showing continents with the highest death count per population

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

