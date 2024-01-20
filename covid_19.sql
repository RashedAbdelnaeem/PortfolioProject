create database covid_19 ;
use covid_19 ;
select * from ..covidDeath where continent is  not null   order by 3 , 4 ;

select * from ..covidVaccinations order by 3 , 4 ;

-- select data that we are going to be useing 
select location , date_ , total_cases , new_cases ,total_deaths , population 
from ..covidDeath order by 1 , 2 ;

-------convert total_cases and total deaths columns to int 
--alter table ..covidDeath alter column total_deaths float ;
--alter table ..covidDeath alter column total_cases float ;

-- looking at total cases vs total death 
--shows likelyhood of dying  if you contarct covid in your country
select location , date_ , total_cases , total_deaths ,  (total_deaths/total_cases )*100 as deathPrecentage 
from ..covidDeath 
where location like 'Eg%'  and  continent is  not null
order by 2 ;

--- looking at total_cases vs population
---- shows what percentage of population got covid 
select location , date_ , population , total_cases   ,  (total_cases/ population)*100 as percentOfpopulationInfected
from ..covidDeath 
where continent is  not null
--where location like 'Eg%' 
order by 2 ;
---looking at highest countries infection compared to population 
select location , population , Max(total_cases) as HighestInfectionCount   , Max( (total_cases/ population))*100 as percentOfpopulationInfected 
from ..covidDeath 
where continent is  not null
--where location like 'Eg%' 
group by location ,population
order by percentOfpopulationInfected desc ;

--let's beark things down by continent 
select location ,Max( cast (  total_deaths as int  )  )  totalDeathCount
from ..covidDeath 
where continent is null
group by location 
order by totalDeathCount desc ;
---
select continent ,Max( cast (  total_deaths as int  )  )  totalDeathCount
from ..covidDeath 
where continent is not null
group by continent 
order by totalDeathCount desc ;

-- showing the countries with highest death count per population 
select location ,Max( cast (  total_deaths as int  )  )  totalDeathCount
from ..covidDeath 
where continent is  not null
group by location 
order by totalDeathCount desc ;

---- showing the continents with highest death count per population 
select location ,Max( cast (  total_deaths as int  )  )  totalDeathCount
from ..covidDeath 
where continent is  not null
group by location 
order by totalDeathCount desc ;

-- Global numbers
select date_ , sum (new_cases ) as TotalCases , sum (new_deaths) as TotalDeath
, (sum (new_deaths )/sum (new_cases))*100 as DeathPercentage
--, total_deaths ,  (total_deaths/total_cases )*100 as deathPrecentage 
from ..covidDeath 
where  continent is  not null
group by date_
order by 1 ,2 ;
-- Total cases in the world
select  sum (new_cases ) as TotalCases , sum (new_deaths) as TotalDeath
, (sum (new_deaths )/sum (new_cases))*100 as DeathPercentage 
from ..covidDeath 
where  continent is  not null
order by 1 ,2 ;

---looking at total population vs vaccination 
select 
dea.location , dea.continent , dea.date_ ,dea.population ,vac.new_vaccinations ,
sum(vac.new_vaccinations ) over (partition by dea.location   order by dea.location ,dea.date_) 
as rollingPeopleVaccinated 
--(rollingPeopleVaccinated/dea.population)*100  --use cte to handel it 
from ..covidDeath   as dea
join ..covidVaccinations as vac 
on dea.location = vac.location
and dea.date_ = vac.date_
where  dea.continent is  not null
order by 1 ,2 ,3
;
---fix null value in new_vaccinations column 
--update  dbo.covidVaccinations
-- set new_vaccinations = 0  
--where new_vaccinations is null ;
--alter table dbo.covidVaccinations alter column new_vaccinations bigint ;


---use CTE to get (rollingPeopleVaccinated/dea.population)*100 
with PopVsVac (continent , location ,date_ , population , new_vaccinations ,rollingPeopleVaccinated)
as
(
select 
dea.location , dea.continent , dea.date_ ,dea.population ,vac.new_vaccinations ,
sum(vac.new_vaccinations ) over (partition by dea.location   order by dea.location ,dea.date_) 
as rollingPeopleVaccinated 
from ..covidDeath   as dea
join ..covidVaccinations as vac 
on dea.location = vac.location
and dea.date_ = vac.date_
where  dea.continent is  not null
)
select * , (rollingPeopleVaccinated/population)*100  as rollingPeopleVaccinatedPercentage
from PopVsVac
;

--Temp table 
Drop table if exists  #PercentPopulationVaccinated ;
create table #PercentPopulationVaccinated (
continent  nvarchar(255),
location   nvarchar(255) ,
date_  datetime ,
population numeric,
new_vaccinations numeric, 
rollingPeopleVaccinated numeric )
insert into  #PercentPopulationVaccinated
select 
dea.location , dea.continent , dea.date_ ,dea.population ,vac.new_vaccinations ,
sum(vac.new_vaccinations ) over (partition by dea.location   order by dea.location ,dea.date_) 
as rollingPeopleVaccinated 
from ..covidDeath   as dea
join ..covidVaccinations as vac 
on dea.location = vac.location
and dea.date_ = vac.date_
--where  dea.continent is  not null
select * ,  (rollingPeopleVaccinated/population)*100 as rollingPeopleVaccinatedPercentage
from #PercentPopulationVaccinated ;

--creating view to store data for later data visualization 
create view PercentPopulationVaccinated as 
select 
dea.location , dea.continent , dea.date_ ,dea.population ,vac.new_vaccinations ,
sum(vac.new_vaccinations ) over (partition by dea.location   order by dea.location ,dea.date_) 
as rollingPeopleVaccinated 
from ..covidDeath   as dea
join ..covidVaccinations as vac 
on dea.location = vac.location
and dea.date_ = vac.date_
--where  dea.continent is  not null
;
select * from  PercentPopulationVaccinated ;
