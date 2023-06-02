--SELECT * FROM [dbo].[CovidDeaths]
--ORDER BY 3, 4
--SELECT * FROM [dbo].[CovidVaccinations]
--ORDER BY 3, 4

--SELECT location, date, total_cases, new_cases, total_deaths, population 
--FROM [dbo].[CovidDeaths]
--ORDER BY 1, 2 

----Total Cases VS Total Deaths (%age of deaths per case) for United States
--SELECT	location, date, total_cases, total_deaths
--		,ROUND((CAST((total_deaths) AS FLOAT) / CAST(total_cases AS FLOAT)) * 100, 5) AS death_percentage
--FROM CovidDeaths
--WHERE location like '%states'
--ORDER BY 1, 2

--Total Cases VS Population (%age of cases per population) for United States
--SELECT	location, date, total_cases, population
--		,ROUND((CAST((total_cases) AS FLOAT) / CAST(population AS FLOAT)) * 100, 5) AS case_percentage
--FROM CovidDeaths
--WHERE location like '%states'
--ORDER BY 1, 2

----Countries with high infection rate(using ROW_NUMBER())
--WITH CTE AS (
--SELECT	location, date, total_cases, population
--		,CAST((total_cases) AS FLOAT) / population * 100 AS case_percentage
--		,ROW_NUMBER() OVER (PARTITION BY location ORDER BY date DESC) AS rownum
--FROM CovidDeaths
--WHERE continent IS NOT NULL
--)
--SELECT	location, population, total_cases, case_percentage
--FROM CTE
--WHERE rownum = 1 
--ORDER BY 4 DESC

----Countries with high infection rate(using MAX())   (better solution)
--SELECT	location, population
--		, MAX(total_cases) AS total_cases
--		, MAX((CAST(total_cases AS FLOAT) / population) * 100) AS case_percentage
--FROM CovidDeaths
--WHERE continent IS NOT NULL
--GROUP BY location, population
--ORDER BY 4 DESC

----Countries with high death count
--SELECT	location, population
--		, MAX(total_deaths) AS total_deaths
--FROM CovidDeaths
--WHERE continent IS NOT NULL
--GROUP BY location, population
--ORDER BY 3 DESC

------Continents with high death count
--SELECT	location AS continent
--		, population
--		, MAX(total_deaths) AS total_deaths
--FROM CovidDeaths
--WHERE continent IS NULL
--GROUP BY location, population
--ORDER BY 3 DESC

--Days with The Most Global Deaths 
--Solution : use SUM() on 'new_cases' & 'new_deaths columns
--SELECT	CAST(date AS date) AS Date
--		,SUM(new_cases) AS Total_Cases
--		,SUM(new_deaths) AS Total_Deaths
--		,(CAST(SUM(new_deaths) AS FLOAT) /SUM(new_cases)) * 100 AS Death_percentage
--FROM CovidDeaths
--WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 3 DESC

--Global Death Percentage (with readable results)
--SELECT	FORMAT(SUM(new_cases), 'N0') AS Total_Cases
--		,FORMAT(SUM(new_deaths), 'N0') AS Total_Deaths
--		,FORMAT((CAST(SUM(new_deaths) AS FLOAT) /SUM(new_cases)),'P3') AS Death_percentage
--FROM CovidDeaths
--WHERE continent IS NOT NULL

--Vacciantion VS Population
--Solution 1: Using CTE
--WITH popVSvac AS (
--SELECT	cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
--		,SUM(cv.new_vaccinations) OVER 
--		(
--			PARTITION BY cd.location
--			ORDER BY cd. location, cd.date
--		) AS running_total
--FROM CovidDeaths cd JOIN CovidVaccinations cv 
--ON cd.location = cv.location AND cd.date = cv.date
--WHERE cd.continent IS NOT NULL
--)
--SELECT *, (running_total/CAST(population AS FLOAT)) * 100 AS [vaccination %age]
--FROM popVSvac

--Solution 2: Using Temp Table
--DROP TABLE IF EXISTS #percentPopVaccinated
--CREATE TABLE #percentPopVaccinated
--(
--continent NVARCHAR(255),
--location NVARCHAR(255),
--date DATETIME,
--population NUMERIC,
--new_vaccinations NUMERIC,
--running_total NUMERIC
--)

--INSERT INTO #percentPopVaccinated
--SELECT	cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
--		,SUM(cv.new_vaccinations) OVER 
--		(
--			PARTITION BY cd.location
--			ORDER BY cd. location, cd.date
--		) AS running_total
--FROM CovidDeaths cd JOIN CovidVaccinations cv 
--ON cd.location = cv.location AND cd.date = cv.date
--WHERE cd.continent IS NOT NULL

--SELECT *, (running_total/CAST(population AS FLOAT)) * 100 AS [vaccination %age]
--FROM #percentPopVaccinated

--Creating View for later Visualizations