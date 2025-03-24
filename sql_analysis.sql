SELECT * FROM netflix_titles.netflix_titles;

select show_id,COUNT(*) 
from netflix_titles
group by show_id 
having COUNT(*)>1;

select * from netflix_titles
where concat(upper(title), type) IN (	select concat(upper(title), type) 
										from netflix_titles
										group by upper(title), type
										having COUNT(*)>1
									)
order by title;

with cte as (
	select * ,
    ROW_NUMBER() over(partition by title, type order by show_id) as rn
	from netflix_titles
	)
select show_id, type, title, cast(date_added as date) as date_added, release_year,
rating, case when duration is null then rating else duration end as duration,description
into netflix
from cte 

select * from netflix_titles;

insert into netflix_country
select show_id, m.country 
from netflix_titles nr inner join (
								select director,country
								from  netflix_country nc
								inner join netflix_directors nd on nc.show_id=nd.show_id
								group by director,country
								) m on nr.director=m.director
where nr.country is null;

select * from netflix_titles where director='Ahishor Solomon';

select director,country
from  netflix_country nc
inner join netflix_directors nd on nc.show_id=nd.show_id
group by director, country;

select * 
from netflix_titles 
where duration is null;

select nd.director 
,COUNT(distinct case when n.type='Movie' then n.show_id end) as no_of_movies
,COUNT(distinct case when n.type='TV Show' then n.show_id end) as no_of_tvshow
from netflix n
inner join netflix_directors nd on n.show_id=nd.show_id
group by nd.director
having COUNT(distinct n.type)>1;

select nc.country , COUNT(distinct ng.show_id ) as no_of_movies
from netflix_genre ng
inner join netflix_country nc on ng.show_id=nc.show_id
inner join netflix n on ng.show_id=nc.show_id
where ng.genre='Comedies' and n.type='Movie'
group by  nc.country
order by no_of_movies desc;

with cte as (
select nd.director,YEAR(date_added) as date_year,count(n.show_id) as no_of_movies
from netflix n
inner join netflix_directors nd on n.show_id=nd.show_id
where type='Movie'
group by nd.director,YEAR(date_added)
), 
cte2 as (
select *, 
ROW_NUMBER() over(partition by date_year order by no_of_movies desc, director) as rn
from cte
order by date_year, no_of_movies desc)
select * from cte2 where rn=1;


select ng.genre, avg(cast(REPLACE(duration,' min',''))) as avg_duration
from netflix n
inner join netflix_genre ng on n.show_id=ng.show_id
where type='Movie'
group by ng.genre;


select nd.director, 
count(distinct case when ng.genre='Comedies' then n.show_id end) as no_of_comedy, 
count(distinct case when ng.genre='Horror Movies' then n.show_id end) as no_of_horror
from netflix n
inner join netflix_genre ng on n.show_id=ng.show_id
inner join netflix_directors nd on n.show_id=nd.show_id
where type='Movie' and ng.genre in ('Comedies','Horror Movies')
group by nd.director
having COUNT(distinct ng.genre)=2;

select * 
from netflix_genre 
where show_id in (select show_id 
					from netflix_directors 
                    where director='Steve Brill')
order by genre;