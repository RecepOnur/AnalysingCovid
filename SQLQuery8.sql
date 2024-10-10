select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

select location, date, total_cases, total_deaths, case when total_cases = 0 then 0 else (total_deaths / total_cases)*100 end AS death_percentage 
from PortfolioProject..CovidDeaths
where location = 'Turkey'
order by 1,2

select location, date, total_cases, population, (total_cases/population)*100 AS infection_percentage
from PortfolioProject..CovidDeaths
where location = 'Turkey'
order by 1,2

select location, population, date, MAX(total_cases) AS MaxInfectionCount,  MAX((total_cases/population))*100 AS infection_percentage
from PortfolioProject..CovidDeaths
group by location, population, date
order by infection_percentage desc

select location, population, MAX(total_cases) AS MaxInfectionCount, MAX((total_cases/population))*100 AS infection_percentage
from PortfolioProject..CovidDeaths
group by location, population
order by infection_percentage desc

-- Countries with their highest deaths

select location, MAX(total_deaths) AS HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc

-- Highest Deaths by every continent

select continent, MAX(total_deaths) AS Total_Deaths
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Total_Deaths desc

Select location, SUM(new_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'European Union (27)', 'International')
and location not like '%income%'
Group by location
order by TotalDeathCount desc


select SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths) /SUM(new_cases) AS death_perc
from PortfolioProject..CovidDeaths
where continent is not null and new_cases is not null
order by 1,2

select distinct
    d.continent, 
    d.location, 
    d.date, 
    d.population, 
    v.new_vaccinations,
    SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location order by d.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as rolling_vaccinations
from PortfolioProject..CovidDeaths as d
join PortfolioProject..CovidVaccinations as v
    on d.location = v.location
    and d.date = v.date
where d.continent is not null 
order by 2, 3;

-- CTE 

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vaccinations) AS (
select distinct
    d.continent, 
    d.location, 
    d.date, 
    d.population, 
    v.new_vaccinations,
    SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location order by d.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as rolling_vaccinations
from PortfolioProject..CovidDeaths as d
join PortfolioProject..CovidVaccinations as v
    on d.location = v.location
    and d.date = v.date
where d.continent is not null 
--order by 2, 3
) select *, (Rolling_Vaccinations/Population)*100 AS VaccinationPercentage
from PopVsVac
where New_Vaccinations is not null


WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vaccinations) AS (
    select
        d.continent, 
        d.location, 
        d.date, 
        d.population, 
        MAX(v.new_vaccinations) as new_vaccinations,
        SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (
            PARTITION BY d.location 
            ORDER BY d.date 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) as rolling_vaccinations
    from PortfolioProject..CovidDeaths as d
    join PortfolioProject..CovidVaccinations as v
        on d.location = v.location
        and d.date = v.date
    where d.continent is not null
    group by d.continent, d.location, d.date, d.population,v.new_vaccinations
)
select *, (Rolling_Vaccinations / Population) * 100 AS VaccinationPercentage
from PopVsVac
order by Location, Date;


