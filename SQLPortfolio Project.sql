Select *
From PortifolioSQL..CovidDeaths$
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortifolioSQL..CovidDeaths$
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage
From PortifolioSQL..CovidDeaths$
Where location like 'Leb%'
and continent is not null 
order by 1,2


-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  round((total_cases/population)*100,2) as PercentPopulationInfected
From PortifolioSQL..CovidDeaths$
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  round(Max((total_cases/population))*100,2) as PercentPopulationInfected
From PortifolioSQL..CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortifolioSQL..CovidDeaths$
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortifolioSQL..CovidDeaths$
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- Compare Death to Total Cases percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, round(SUM(cast(new_deaths as int))/SUM(New_Cases)*100,2) as DeathPercentage
From PortifolioSQL..CovidDeaths$
where continent is not null 
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortifolioSQL..CovidDeaths$ dea
Join PortifolioSQL..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortifolioSQL..CovidDeaths$ dea
Join PortifolioSQL..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortifolioSQL..CovidDeaths$ dea
Join PortifolioSQL..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortifolioSQL..CovidDeaths$ dea
Join PortifolioSQL..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

