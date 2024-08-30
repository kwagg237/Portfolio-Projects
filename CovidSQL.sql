--Covid 19 Data Exploration

--Skills used: Joins, CTEs, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

select *
from CovidDeaths
where continent is not null
order by 3,4

select *
from PortfolioProject.dbo.CovidVaccinations
order by 3,4


--Select Data that we are going to use

select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows the proportion of deaths of people with a confirmed Covid diagnosis

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as CaseFatalityRate
from CovidDeaths
where location like '%states%'
order by 1,2


--Looking at Total Cases vs Population 
--Shows the Prevalence of Covid, or the percentage of the population infected with Covid

select location, date, population, total_cases, (total_cases/population)*100 as Prevalence
from CovidDeaths
where location like '%states%'
order by 1,2


--Looking at Countries with highest Prevalence

select location, population, max(total_cases) as MaxInfectionCount, max((total_cases/population))*100 as Prevalence
from CovidDeaths
--where location like '%states%'
group by location, population
order by Prevalence desc;


--Showing Countries with highest Death Count per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


--Filter by Continent 

--select location, max(cast(total_deaths as int)) as TotalDeathCount
--from CovidDeaths
----where location like '%states%'
--where continent is null
--group by location
--order by TotalDeathCount desc


--Showing Continents with Highest Death Count

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Total Global Cases, Deaths, and Case Fatality Rate

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as CaseFatalityRate
from CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--Global Numbers of Cases, Deaths, and Case Fatality Rate by day

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as CaseFatalityRate
from CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2


--Looking at Total Populaion vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RunningVaccinationCount
--,(RunningVaccinationCount/population)*100
from CovidDeaths dea
Join CovidVaccinations vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Using CTE with previous query to find the Percent of the Population Vaccinated for each Country

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RunningVaccinationCount)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RunningVaccinationCount
--,(RunningVaccinationCount/population)*100
from CovidDeaths dea
Join CovidVaccinations vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RunningVaccinationCount/Population)*100 as PercentPopulationVaccinated
from PopvsVac


--Using Temp Table with previous query to find the Percent of the Population Vaccinated for each Country

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RunningVaccinationCount numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RunningVaccinationCount
--,(RunningVaccinationCount/population)*100
from CovidDeaths dea
Join CovidVaccinations vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RunningVaccinationCount/Population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated


--Creating View to store data for later visualizations to find the Running Vaccination Count

Create View RunningVacCount as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RunningVaccinationCount
--,(RunningVaccinationCount/population)*100
from CovidDeaths dea
Join CovidVaccinations vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from RunningVacCount