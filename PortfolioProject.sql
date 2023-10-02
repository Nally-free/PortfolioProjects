select *
from Portfolio.dbo.CovidDeaths
order by 3, 4

--select *
--from Portfolio.dbo.CovidVaccinations
--order by 3, 4

/*Get the columns needed */
select Location, date, total_cases,	new_cases, total_deaths, population
from Portfolio.dbo.CovidDeaths
order by 1,2

/*Total_deaths VS Total_cases */
select Location, date, total_cases,	total_deaths, (total_deaths/total_cases)*100 as '% Deaths'
from Portfolio.dbo.CovidDeaths
where Location like '%viet%'
order by 1,2

/*Total_cases VS Population */
select Location, date, total_cases,	population, (total_cases/population)*100 as '% Cases'
from Portfolio.dbo.CovidDeaths
where Location like '%state%'
order by 1,2

/*Countries with the highest infected rate compared to population */
select Location, population, max(total_cases) as HighestCases, max((total_cases/population))*100 as 'Highest % Cases'
from Portfolio.dbo.CovidDeaths
where continent is not null
group by Location, population
order by 4 desc

/*Countries with the highest deaths compared to population */
select Location, max(cast(total_deaths as int)) as HighestDeaths
from Portfolio.dbo.CovidDeaths
where continent is not null
group by Location
order by 2 desc

/*Sort total_deaths by Continent */
select Location, max(cast(total_deaths as int)) as HighestDeaths
from Portfolio.dbo.CovidDeaths
where continent is null
group by Location
order by 2 desc

/*Global Numbers */
select Date, sum(cast(new_cases as int)) as AllCases, 
			sum(cast(new_deaths as int)) as AllDeaths, 
			sum(cast(new_deaths as int))/sum(new_cases) as '% D/C'		
from Portfolio.dbo.CovidDeaths
where continent is NOT null
group by Date
order by 1


/*Create a temp table to use the division formula */
drop table if exists #PercentVac 
create table #PercentVac
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
AllVac numeric)
--
insert into #PercentVac 
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over 
	(partition by dth.location order by dth.location, dth.date) as AllVac
from Portfolio.dbo.CovidDeaths dth
join Portfolio.dbo.CovidVaccinations vac
	on dth.date = vac.date and dth.location = vac.location
where dth.continent is NOT null
order by 2,3
--
select *, (AllVac/population)*100 as '%Vac' /* <== all the thangs just to execute this */
from #PercentVac 


create view PercentVac as
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over 
	(partition by dth.location order by dth.location, dth.date) as AllVac
from Portfolio.dbo.CovidDeaths dth
join Portfolio.dbo.CovidVaccinations vac
	on dth.date = vac.date and dth.location = vac.location
where dth.continent is NOT null
--order by 2,3

select *
from PercentVac