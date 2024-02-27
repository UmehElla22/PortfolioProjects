select *
from CovidDeaths
where continent is NOT null
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

--looking at total cases vs total deaths
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercent
from CovidDeaths
where location like '%Nigeria%'
and continent is NOT null
order by 1,2

--looking at total cases vs population (shows % of ppl that got covid)

select location,date,total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location like '%Nigeria%'
and continent is NOT null
order by 1,2

--Countries with highest infection rate compared to population

select location,population,max (total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
--where location like '%Nigeria%'
group by location, population
order by PercentPopulationInfected desc

--Countries with Highest deaths count per population

select location,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%Nigeria%'
where continent is null
group by location
order by TotalDeathCount desc

--let's break things down by continents
--showing the continents with the highes deaths counts

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select date,SUM (new_cases) as Total_cases,sum(cast(new_deaths as int))as Total_deaths,
sum(cast(new_deaths as int)) /SUM(new_cases)*100 as DeathPercent
from CovidDeaths
--where location like '%Nigeria%'
where continent is NOT null
group by date
order by 1,2


--GENERAL total across the world

select SUM (new_cases) as Total_cases,sum(cast(new_deaths as int))as Total_deaths,
sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercent
from CovidDeaths
--where location like '%Nigeria%'
where continent is NOT null
order by 1,2

--JOINING COVID DEATH /VACCINATION TABLE

SELECT*
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
ON DEA.location= VAC.location
AND DEA.date=VAC.date

--LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
ON DEA.location= VAC.location
AND DEA.date=VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3


--USING CTE TO MAKE EVERYTHING EASY FOR CALCULATION

WITH PopVsVac (continent, location, date, population,new_vaccinations,RollingPeopleVaccinated) as
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT(INT,VAC.new_vaccinations)) 
OVER(PARTITION BY DEA.Location ORDER BY DEA.Location, DEA.date)AS RollingPeopleVaccinated
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
ON DEA.location= VAC.location
AND DEA.date=VAC.date
WHERE DEA.continent IS NOT NULL
)
select*, (RollingPeopleVaccinated/population)*100
from PopVsVac

--USING A TEMP TABLE FOR SAME THING

drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime ,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT(INT,VAC.new_vaccinations)) 
OVER(PARTITION BY DEA.Location ORDER BY DEA.Location, DEA.date)AS RollingPeopleVaccinated
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
ON DEA.location= VAC.location
AND DEA.date=VAC.date
WHERE DEA.continent IS NOT NULL

select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualization 

create view PercentPopulationVaccinated as
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT(INT,VAC.new_vaccinations)) 
OVER(PARTITION BY DEA.Location ORDER BY DEA.Location, DEA.date)AS RollingPeopleVaccinated
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
ON DEA.location= VAC.location
AND DEA.date=VAC.date
WHERE DEA.continent IS NOT NULL