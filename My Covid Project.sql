select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..Covidvaccinations
--order by 3,4

--Select the data we will be working with

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



--I will be looking at Total cases VS Total Death.This helps to know the chances of surviving Covid

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
order by 1,2

--Let's look at the Total cases Vs population.This shows us the percentage of the population that got Covid
select location,date,population,total_cases, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
order by 1,2

--Looking at Countries with the Highest Infection Rate In comparison with population
select location,population,Max(total_cases) as HighestInfection, Max((total_cases/population))*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
Group by location,population
order by InfectedPercentage desc


--LET US BREAK THEM DOWN BY THEIR CONTINENTS
select location,Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is null
Group by location
order by TotalDeathCount desc


--Showing Continents With The Highest Death Count Per Population
select continent,Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum
(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by date
order by 1,2

--For the total number of death and death percentage globally

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum
(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
--group by date
order by 1,2

--LET'S JOIN COVID DEATHS AND COVID VACCINATIONS TOGETHER

select * 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


--Looking at the total population vs Vaccinations



select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as decimal)) OVER (partition by dea.location)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--OR We can also use convert function

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(decimal,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Now We need the MAX number of our RollingPeopleVaccination(divided by the population) to know the Total Population VS Vaccinations.
--But in SQL,we can't work with a new column created.So we will have to create CTEs or TempTable.


--WITH CTEs;
with popVsvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(decimal,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*,(RollingPeopleVaccinated/population)*100
from popVsvac

--WITH TEMP TABLE

DROP table if exists #percentagePopulationVaccinated
Create Table #percentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentagePopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(decimal,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select*,(RollingPeopleVaccinated/population)*100
from #percentagePopulationVaccinated



--Creating view for future Visuals

Create View PercentagePopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(decimal,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentagePopulationVaccinated
