-- All Tables
Select *
From MovieTitle

Select *
From MovieCredit





-- Movie vs Show Count
Select type ,Count(*) as MovieTypeCount
From MovieTitle
Group By type
order by MovieTypeCount DESC





-- Movie age_certification

/*
Because there are blank space in age_certification column, we need to replace it to 'Unrated'
*/

Update MovieTitle
SET age_certification = 'Unrated'
Where age_certification = ''

Select 
	age_certification, 
	Count(*) As CertCount
From MovieTitle
Group By age_certification
Order by CertCount DESC


/* 
Unrated	: Doesnt have certification
TV-MA	:
R		:
TV-14	:
PG-13	:
PG		:
TV-PG	:
G		:
TV-Y7	:
TV-Y	:
TV-G	:
NC-17	:
*/





-- Based on genre
Select id, genres
From MovieTitle

/* Because genres column is an array we need to turn it into single value. Then put it in a new table */

/* The new table */
Create Table MovieGenre 
(
id Nvarchar(255),
Movie_genre Nvarchar(255)
)

/* Temporary table to process the data */
CREATE TABLE #Temp_MovieGenre
(
id nvarchar(255),
genre nvarchar(255)
)

Insert Into #Temp_MovieGenre
Select id, genres
From MovieTitle

/* removing The '[]' */
Update #Temp_MovieGenre
Set genre = Replace(Replace(genre,'[',''),']','')

/* spliting the value then insert into MovieGenre table */
INSERT INTO MovieGenre 
SELECT id, value
FROM #Temp_MovieGenre
	CROSS APPLY string_split(genre, ',')

/* removing the blank space */
Update MovieGenre
Set Movie_genre = TRIM(Movie_genre)

/* Defining the blank value with 'Unspecified' */
Update MovieGenre
SET Movie_genre = 'Unspecified'
Where Movie_genre = ' '

/* Checking if there is a dupicated value */
With CTE
as (
Select *, ROW_NUMBER() Over (Partition By id, Movie_genre Order By id, Movie_Genre) row_num
From MovieGenre)

Select * From CTE
Where row_num > 1

/* How many movies per genre */
Select Movie_genre, Count(*) as GenreCount
from MovieGenre
Group By Movie_genre
Order by GenreCount Desc





-- Production Per Country
Select id, title, production_countries
From MovieTitle

/* Because genres column is an array we need to turn it into single value. Then put it in a new table */

/* The new table */
Create Table MovieProductionCountry 
(
id Nvarchar(255),
ProductionCountry Nvarchar(255)
)

/* Temporary table to process the data */
CREATE TABLE #Temp_MovieProductionCountry 
(
id nvarchar(255),
prd_cty nvarchar(255)
)

Insert Into #Temp_MovieProductionCountry
Select id, production_countries
From MovieTitle

/* removing The '[]' */
Update #Temp_MovieProductionCountry
Set prd_cty = Replace(Replace(prd_cty,'[',''),']','')

/* spliting the value then insert into MovieProductionCountry table */
INSERT INTO MovieProductionCountry  
SELECT id, value
FROM #Temp_MovieProductionCountry
	CROSS APPLY string_split(prd_cty, ',')

/* Checking if there is a dupicated value */
With CTE
as 
(Select *, ROW_NUMBER() Over (Partition By id, ProductionCountry Order By id, ProductionCountry) row_num
From MovieProductionCountry)

Select * From CTE
Where row_num > 1

/* removing the blank space */
Update MovieProductionCountry
Set ProductionCountry = TRIM(ProductionCountry)

/* Defining the blank value with 'Unspecified' */
Update MovieProductionCountry
SET ProductionCountry = 'Unspecified'
Where ProductionCountry = ' '

/* How many movies per country */
Select ProductionCountry, Count(*) as CountryCount
from MovieProductionCountry
Group By ProductionCountry
Order by CountryCount Desc




-- Movie Per Released Year
Select release_year, Count(*) AS YearCount
From MovieTitle
Group By release_year
Order By YearCount Desc



select * From MovieTitle

-- Average IMD Score Per Genre
With CTE
As (
Select Movie_genre, imdb_score
From MovieGenre
Join MovieTitle
	ON MovieTitle.id = MovieGenre.id
		AND MovieTitle.imdb_score IS NOT NULL
)

Select Movie_genre, AVG(imdb_score) as AvgRating
From CTE
Where Movie_genre != 'Unspecified'
Group By Movie_genre
Order By AvgRating DESC




-- IMDB Scores Per Genre With Above average IMDB_Votes
Select Avg(imdb_votes)
From MovieTitle

/* the average votes is 234393,824738416. We round it to 234394 */
With CTE
As (
Select Movie_genre, imdb_score, imdb_votes
From MovieGenre
Join MovieTitle
	ON MovieTitle.id = MovieGenre.id
		AND MovieTitle.imdb_score IS NOT NULL
		AND imdb_votes >= 234394
)

Select Movie_genre, AVG(imdb_score) as AvgRating
From CTE
Where Movie_genre != 'Unspecified'
Group By Movie_genre
Order By AvgRating DESC


