--Select *
--From PortfolioProject1..CovidDeaths
--Order by 3,4

--Select *
--From PortfolioProject1..CovidVaccinations
--Order by 3,4


--Select data to start with

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
Where continent is not null
Order by 1,2


--Total Cases vs Total Deaths
--Shows the likelihood of death from contracting Covid in the United States at certain times.

Select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100, 2) As DeathPercentage
From PortfolioProject1..CovidDeaths
Where location = 'United States'
And continent is not null
Order by 1,2


--Total Cases vs Population
--Shows what percent of population contracted Covid

Select location, date, total_cases, population, round((total_cases/population)*100, 2) As PercentPopulationInfected
From PortfolioProject1..CovidDeaths
Order by 1,2


--Countries with highest infection rate compared to Population

Select location, population, Max(total_cases) As HighestInfectionCount, round(Max((total_cases/population))*100, 2) As PercentPopulationInfected
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by location, population
Order by PercentPopulationInfected DESC


--Countries with highest death count per population

Select location, Max(cast(total_deaths As int)) As TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount DESC


--BROKEN DOWN BY CONTINENT; SHOWING HIGHEST DEATH COUNT PER POPULATION

Select continent, Max(cast(total_deaths As int)) As TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount DESC


--GLOBAL NUMBERS

Select Sum(new_cases) As total_cases, Sum(Cast(new_deaths As int)) As total_deaths, Round(Sum(Cast(new_deaths As int))/Sum(new_cases)*100, 2) as DeathPercentage
From PortfolioProject1..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2


--Total Population vs Vaccinations
--Shows percentage of population that has received atleast 1 Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Cast(vac.new_vaccinations As int)) Over (Partition by dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--Using CTE to complete calculation in Partition statement in previous query

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Cast(vac.new_vaccinations As int)) Over (Partition by dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 As RollingPercentVaccinated
From PopvsVac


--Using Temp Table to complete calculation in Partition statement in previous query

Drop Table if Exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Cast(vac.new_vaccinations As int)) Over (Partition by dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 As RollingPercentVaccinated
From #PercentPopulationVaccinated


--Creating View to store data for later visualization

Create View PercentPopulationVaccinated As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Cast(vac.new_vaccinations As int)) Over (Partition by dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null