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



