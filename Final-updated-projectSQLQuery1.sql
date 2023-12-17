select * 
from UpdatedPortFolioProject.dbo.['covid_deaths']
where continent is not null
order by 3,4


select * 
from UpdatedPortFolioProject.dbo.['covid_vaccinations']
order by 3,4


-- select data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from UpdatedPortFolioProject.dbo.['covid_deaths']
order by 1,2


--looking at total cases vs total deaths


select  location,date,total_cases,total_deaths,
(convert(float,total_deaths)/nullif(convert(float,total_cases),0))*100 as DeathPercentage
from UpdatedPortFolioProject.dbo.['covid_deaths']
where location like '%india%'
order by 1,2


-- total cases vs Population
-- shows what percentage of population got Covid

select  location,date,total_cases,total_deaths,
(convert(float,total_deaths)/nullif(convert(float,total_cases),0))*100 as DeathPercentage
from UpdatedPortFolioProject.dbo.['covid_deaths']
where location like '%states%'
order by 1,2


select location,date,population,total_cases,
(total_cases/population)*100 as DeathPercentage
from UpdatedPortFolioProject.dbo.['covid_deaths']
where location like '%states%'
order by 1,2

-- Looking at countries with highest infenction rate


select location,population,max(total_cases) as HighestInfectionCount,
max((total_cases/population))*100 as DeathPercentage
from UpdatedPortFolioProject.dbo.['covid_deaths']
--where location like '%states%'
group by location,population
order by DeathPercentage desc


-- Showing countries with highest death count per population


select location, max(cast(total_deaths as int)) as TotalDeathCount
from UpdatedPortFolioProject.dbo.['covid_deaths']
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


-- lets break things down by continent


select continent, max(cast(total_deaths as int)) as TotalDeathCount
from UpdatedPortFolioProject.dbo.['covid_deaths']
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- deaths by location

select location, max(cast(total_deaths as int)) as TotalDeathCount
from UpdatedPortFolioProject.dbo.['covid_deaths']
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc


-- Breaking by Global Numbers

select date,sum(new_cases)--,total_cases,total_deaths,
--(total_deaths/total_cases)*100 as DeathPercentage
from UpdatedPortFolioProject.dbo.['covid_deaths']

where continent is not null
group by date
order by 1,2


select date,sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from UpdatedPortFolioProject.dbo.['covid_deaths']

where continent is not null
group by date
order by 1,2



select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from UpdatedPortFolioProject.dbo.['covid_deaths']

where continent is not null
--group by date
order by 1,2


-- Looking at total population vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations
from UpdatedPortFolioProject.dbo.['covid_deaths'] dea

join UpdatedPortFolioProject.dbo.['covid_vaccinations'] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 1,2,3


-- New Vaccination in a country (Any COuntry)

select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations
from UpdatedPortFolioProject.dbo.['covid_deaths'] dea

join UpdatedPortFolioProject.dbo.['covid_vaccinations'] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
and dea.location like '%canada%'
order by 1,2,3



-- Using Partition by location only

select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.location)
from UpdatedPortFolioProject.dbo.['covid_deaths'] dea

join UpdatedPortFolioProject.dbo.['covid_vaccinations'] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 1,2,3


-- Partition by location and date both (order by location and date)

select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,sum(cast (vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from UpdatedPortFolioProject.dbo.['covid_deaths'] dea

join UpdatedPortFolioProject.dbo.['covid_vaccinations'] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

with PopsVac (continent, Location,date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,sum(cast (vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from UpdatedPortFolioProject.dbo.['covid_deaths'] dea

join UpdatedPortFolioProject.dbo.['covid_vaccinations'] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select *
from PopsVac



-- using percentage

with PopsVac (continent, Location,date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,sum(cast (vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from UpdatedPortFolioProject.dbo.['covid_deaths'] dea

join UpdatedPortFolioProject.dbo.['covid_vaccinations'] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100 
from PopsVac



-- Temp Table

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated

select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,sum(cast (vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from UpdatedPortFolioProject.dbo.['covid_deaths'] dea

join UpdatedPortFolioProject.dbo.['covid_vaccinations'] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3


select *, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated



-- making changes

drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated

select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,sum(cast (vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from UpdatedPortFolioProject.dbo.['covid_deaths'] dea

join UpdatedPortFolioProject.dbo.['covid_vaccinations'] vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3


select *, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated



-- Creating View to store data for later Visualizations

create view PercentVaccinated as
select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,sum(cast (vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from UpdatedPortFolioProject.dbo.['covid_deaths'] dea

join UpdatedPortFolioProject.dbo.['covid_vaccinations'] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentVaccinated

-- above code creates the permanent table so that we dont have to create temporary tables everytime