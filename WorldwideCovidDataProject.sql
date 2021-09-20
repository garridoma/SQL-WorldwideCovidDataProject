
-- select * from dbo.CovidDeaths
-- order by 3,4;

-- select * from dbo.CovidVaccinations
-- order by 3,4;


-- Select key Info
select Location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1,2;


-- Total Cases vs Total Deaths Ratio (now)
-- Shows the likelihood of dying if you get covid (in the States sorted by date)
select Location, date, total_cases, total_deaths, (total_deaths/total_cases) as death_cases_ratio
from dbo.CovidDeaths
where location like '%states%'
order by 1,2 desc

-- Total Cases vs Total Deaths Ratio (max)
-- Shows the likelihood of dying if you get covid (in the States sorted by ratio)
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_cases_ratio
from dbo.CovidDeaths
where location like '%states%'
order by 5 desc

-- Total Cases vs Population (infection rate in the States)
-- Shows percentage of population that got Covid (through all time)
select Location, date, total_cases, population, (total_cases/population)*100 as cases_pop_ratio
from dbo.CovidDeaths
where location like '%states%'
order by 5 desc

-- Countries with highest Infection Rate
select Location, max((total_cases/population)*100) as cases_pop_ratio
from dbo.CovidDeaths
group by Location
order by 2 desc

-- Countries with highest Deaths count per population
select Location, max((total_deaths/population)*100) as death_pop_ratio
from dbo.CovidDeaths
group by Location
order by 2 desc

-- Countries with highest Death rate (deaths vs cases)
select Location, (sum(total_deaths)/sum(total_cases))*100 as death_cases_ratio
from dbo.CovidDeaths
group by Location
order by 2 desc

-- Countries with highest death count
select location, max(total_deaths) as countries_death_count
from dbo.CovidDeaths
where continent is not null
group by location
order by 2 desc

--Continents with highest death count
select continent, max(total_deaths) as continents_death_count
from dbo.CovidDeaths
where continent is not null
group by continent
order by 2 desc

-- Death rate each day around the world (sorted by highest ratio)
select date, (SUM(new_deaths)/SUM(new_cases))*100 death_rate
from dbo.CovidDeaths
where new_deaths > 0 and new_cases > 0
group by date
order by 2 desc

-- Total Population vaccinated evolution in the States
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as vaccinations_evo
from PortfolioProject..CovidDeaths deaths
inner join PortfolioProject..CovidVaccinations vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null and deaths.location like '%states%'
order by 2, 3

-- Percentage of population vaccinated evolution in the States (using CTE)
With PercPopVacc (continent, location, date, population, new_vaccinations, vaccinations_evo)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as vaccinations_evo
from PortfolioProject..CovidDeaths deaths
inner join PortfolioProject..CovidVaccinations vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null and deaths.location like '%states%'
)
select *, ((vaccinations_evo/population)*100/2) as pct_pop_vaccinated
from PercPopVacc

-- Percentage of population vaccinated evolution in the States (using Temp Table)
DROP Table if exists PercPopVacc
Create Table PercPopVacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vaccinations_evo numeric
)
Insert into PercPopVacc
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as vaccinations_evo
from PortfolioProject..CovidDeaths deaths
inner join PortfolioProject..CovidVaccinations vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null and deaths.location like '%states%'

select *, ((vaccinations_evo/population)*100/2) as pct_pop_vaccinated
from PercPopVacc

-- Create a view for later using it in a visualization tool
Create View EvolutionVaccinatedPopulationStates as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as vaccinations_evo
from PortfolioProject..CovidDeaths deaths
inner join PortfolioProject..CovidVaccinations vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null and deaths.location like '%states%'