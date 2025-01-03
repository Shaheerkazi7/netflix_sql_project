drop table if exists netflix;
Create table netflix (
	show_id	VARCHAR(50),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

select * from netflix
--1. Count the number of Movies vs TV Shows

select type ,
count(*)
from netflix
group by 1;

---2. Find the most common rating for movies and TV shows
select type ,
rating 
from

(select 
		type,
		rating,
		count(*),
		rank() over(partition by type order by count(*) desc) as ranking 
		from netflix
		group by 1,2
) as t1 
where ranking = 1;


--3. List all movies released in a specific year (e.g., 2020)
select title,
release_year 
from netflix
where 
release_year = 2020 and type = 'Movie' 
order by 1;

--4. Find the top 5 countries with the most content on Netflix
SELECT * 
FROM
(
	SELECT 
		-- country,
		UNNEST(STRING_TO_ARRAY(country, ',')) as country,
		COUNT(*) as total_content
	FROM 
	netflix
	GROUP BY 1
)as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

--5. Identify the longest movie

select type,
duration
from netflix 
where type = 'Movie' and duration is not null
order by SPLIT_PART(duration,' ',1):: int DESC;



---- 6. Find content added in the last 5 years
SELECT
*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

select release_year,
		count(release_year)
		from netflix
		where release_year >= 2017
		group by 1
		order by 2 desc;



---- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select title,director_name
from(



select * ,
UNNEST(string_to_array(director,',')) as director_name
from netflix
) 
where director_name = 'Rajiv Chilaka';



-- 8. List all TV shows with more than 5 seasons
select * 
from netflix
where 	
	type = 'TV Show' and 		
	split_part(duration,' ',1):: INT > 5;

-- 9. Count the number of content items in each genre
select unnest(string_to_array(listed_in,',')) as genre,
count(*) as total_content
from netflix
group by 1
order by 2 desc;

-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !
select country,
	release_year,
	count(show_id)as total_release,
		Round(count(show_id)::numeric/
		(select count(show_id) from netflix where country = 'India')::numeric * 100 ,2) 
		as avg_release
	from netflix
	where country = 'India' 
	group by 1,2
	order by avg_release desc
	limit 5;

-- 11. List all movies that are documentaries
select * from netflix
where listed_in like '%Documentaries'


-- 12. Find all content without a director
select * from netflix 
where director is null;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * from netflix 
where casts like '%Salman Khan%'
and release_year > extract(year from current_date) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.


select 
unnest(string_to_array(casts,','))as actor,
count(*)
from netflix
where netflix.country = 'India'
group by 1 
order by 2 desc
limit 10;


/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/


select category,
type,
count(show_id) as content_count
from
(
select * ,
case 
when description like '%kill%' or description like '%violence%' then 'Bad'
else 'Good' end as category
from netflix
) as t2
group by 1,2
order by 3 desc 


-- End of reports






















