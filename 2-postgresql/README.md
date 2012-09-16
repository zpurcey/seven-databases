# Week 1 Study Notes

## GIT Notes

### Clone a repo

```
git clone https://github.com/zpurcey/seven-databases.git
git remote add upstream https://github.com/codingbynumbers/seven-databases.git
# Crap just realised my upstream is my account not codingbynumbers.  How do I change my upstream remote?
git fetch upstream
git merge upstream/master
```
**Question:** Will merging (just cause I fixed the upstream remote) risk my VM getting reverted and lose db changes to date?

I branched Day 3 although not sure if this is where it would merge given it says upstream/**master**.  Seemed to work:

```
Andrew-Purcells-MacBook-Pro-2:2-postgresql apurcell$ git merge upstream/master
Merge made by the 'recursive' strategy.
 2-postgresql/provision.sh                   |  26 ++-
 3-riak/.kerl/archives/MD5                   | 265 +++++++++++++++++++++++++++
 3-riak/.kerl/archives/otp_src_R15B01.tar.gz | Bin 0 -> 75592537 bytes
 3-riak/Vagrantfile                          |  97 ++++++++++
 3-riak/kerl                                 | 902 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3-riak/provision.sh                         |  33 ++++
 3-riak/readme.md                            |  11 ++
 3-riak/riak-1.2.0.tar.gz                    | Bin 0 -> 11208518 bytes
 8 files changed, 1325 insertions(+), 9 deletions(-)
 create mode 100644 3-riak/.kerl/archives/MD5
 create mode 100644 3-riak/.kerl/archives/otp_src_R15B01.tar.gz
 create mode 100644 3-riak/Vagrantfile
 create mode 100755 3-riak/kerl
 create mode 100755 3-riak/provision.sh
 create mode 100644 3-riak/readme.md
 create mode 100644 3-riak/riak-1.2.0.tar.gz
```

### Commit a new file

```
cd seven-databases
touch README.md
git add README.md
git commit -m 'commit comments'
git push origin master
```

### Create a Branch?

```
git branch mybranch
# Creates a new branch called "mybranch"

git checkout mybranch
# Makes "mybranch" the active branch

git checkout -b mybranch
# Creates a new branch called "mybranch" and makes it the active branch

git checkout master
# Makes "master" the active branch

git merge mybranch
# Merges the commits from "mybranch" into "master"

git branch -d mybranch
# Deletes the "mybranch" branch

git branch mybranch
# Creates a new branch called "mybranch"

```

## DAY 3 Notes

Levenshtein is a string comparison algorithm that compares how similar two strings are by how many steps are required to change one string into another.
This is so interesting - I've wondered how to go about fuzzy string matches for search or suggestions.

**Question:** metaphone(name,8) <= What is the second argument (8) for?

  metaphone(text source, int max_output_length) returns text max_output_length
  The Second Arg sets the maximum length of the output metaphone code; if longer, the output is truncated to this length.

Cubes are freaking awesome!  Love it.  Not sure how I missed this lecture at Uni. Perhaps it's time to go back :)
Being able to expand or reduce the cube makes so much sense, love seeing this side of tackling bigger data problems using SQL.
Looking forward to "... two-dimensional geographic searches in MongoDB"

"Beyond the core power of SQL, contrib packages are what makes PostgreSQL shine."
- Cool learned lots the DB2 package concept is new to me and really blurs the line on what belongs in code or in the db.

## Day 1 Homework
### Find
1. Bookmark the online PostgreSQL FAQ and documents.

``http://www.postgresql.org/docs/``
``http://www.postgresql.org/docs/faq/``

2. Acquaint yourself with the command-line \? and \h output.

3. In the addresses FOREIGN KEY, find in the docs what MATCH FULL means.

``http://www.postgresql.org/docs/8.1/static/sql-createtable.html``

MATCH FULL will not allow one column of a multicolumn foreign key to be null unless all foreign key columns are null. 

### Do

1. Select all the tables we created (and only those) from pg_class.

```
SELECT *
FROM (((events e LEFT JOIN venues v ON e.venue_id = v.venue_id)
LEFT JOIN cities ci ON v.postal_code = ci.postal_code and v.country_code = ci.country_code)
LEFT JOIN countries co ON ci.country_code = co.country_code);
```

2. Write a query that finds the country name of the LARP Club event.

```
SELECT co.country_name
FROM (((events e LEFT JOIN venues v ON e.venue_id = v.venue_id)
LEFT JOIN cities ci ON v.postal_code = ci.postal_code and v.country_code = ci.country_code)
LEFT JOIN countries co ON ci.country_code = co.country_code)
WHERE e.title = 'LARP Club';
```
Do we have to join the cities table? Why not just create a foreign key to countries?  Pros/Cons

3. Alter the venues table to contain a boolean column called active, with the default value of TRUE.

```
ALTER TABLE venues ADD COLUMN active boolean DEFAULT TRUE;
```

## Day 2 Homework
### Find
1. Find the list of aggregate functions in the PostgreSQL docs.

``http://www.postgresql.org/docs/8.2/static/functions-aggregate.html``

2. Find a GUI program to interact with PostgreSQL, such as Navicat.

``http://www.navicat.com/en/products/navicat_pgsql/pgsql_detail_mac.html``

### Do 					 							
1. Create a rule that captures DELETEs on venues and instead sets the active flag (created in the Day 1 homework) to FALSE.
```
CREATE RULE delete_venues AS ON DELETE TO venues DO INSTEAD
UPDATE venues SET active = FALSE
WHERE venue_id = old.venue_id;
```

2. A temporary table was not the best way to implement our event calendar pivot table. The generate_series(a, b) function returns a set of records, from a to b. Replace the month_count table SELECT with this. 

```		 	 	 		
SELECT * FROM crosstab
  ('SELECT extract(year from starts) as year, extract(month from starts) as month, count(*)
    FROM events
    GROUP BY year, month', 'SELECT * FROM generate_series(1,12)')
  AS (year int, jan int, feb int, mar int, apr int, may int,
      jun int, jul int, aug int, sep int, oct int, nov int,
      dec int)
  ORDER BY YEAR;
```

3. Build a pivot table that displays every day in a single month, where each week of the month is a row and each day name forms a column across the top (seven days, starting with Sunday and ending with Saturday) like a standard month calendar. Each day should contain a count of the number of events for that date or should remain blank if no event occurs. 

```
SELECT * FROM crosstab
  ('SELECT extract(week from starts) as week, extract(dow from starts) as day, count(*)
    FROM events
    WHERE starts >= ''2012-02-01'' AND starts <= ''2012-02-28''
    GROUP BY week, day', 'SELECT * FROM generate_series(0,6)')
  AS (Week int, Sun int, Mon int, Tue int, Wed int, Thu int,
      Fri int, Sat int)
  ORDER BY week;
```

## DAY 3 Notes

Levenshtein is a string comparison algorithm that compares how similar two strings are by how many steps are required to change one string into another.
This is so interesting - I've wondered how to go about fuzzy string matches for search or suggestions.

**Question:** metaphone(name,8) <= What is the second argument (8) for?

  metaphone(text source, int max_output_length) returns text max_output_length
  The Second Arg sets the maximum length of the output metaphone code; if longer, the output is truncated to this length.

Cubes are freaking awesome!  Love it.  Not sure how I missed this lecture at Uni. Perhaps it's time to go back :)
Being able to expand or reduce the cube makes so much sense, love seeing this side of tackling bigger data problems using SQL.
Looking forward to "... two-dimensional geographic searches in MongoDB"

"Beyond the core power of SQL, contrib packages are what makes PostgreSQL shine."
- Cool learned lots the DB2 package concept is new to me and really blurs the line on what belongs in code or in the db.

## Day 3 Homework
### Find
#### 1. Find online documentation of all contributed packages bundled into Postgres.
 http://www.postgresql.org/docs/8.3/static/contrib.html

#### 2. Find online POSIX regex documentation (it will also be handy for future chapters).
 http://www.postgresql.org/docs/8.1/static/functions-matching.html#FUNCTIONS-POSIX-TABLE

### Do
**1. Create a stored procedure where you can input a movie title or actor’s name you like,**
**and it will return the top five suggestions based on either movies the actor has starred in**
**or films with similar genres.**

movie_genuius(text) is the main stored proc
- Calls fuzzy_suggest() to retrieve close match movies and actors
- Selects closest match and retrieves top 5 titles using movie_by_actor() or movie_by_genre()

**movie_genuius Example Output:**
```
select * from movie_genuius('Star Wars');
NOTICE:  Returning similar movies by Genre for Star Wars
                  top_5_titles                  
------------------------------------------------
 Star Wars: Episode V - The Empire Strikes Back
 Avatar
 Explorers
 Krull
 E.T. The Extra-Terrestrial
```

**movie_genuius Code:**
```
CREATE OR REPLACE FUNCTION movie_genuius(search_text text)
RETURNS TABLE (top_5_titles text) AS $$

DECLARE
key text;
type text;

BEGIN
  key = '';
  type = '';
  
  select suggested_keyword, keyword_type into key, type from fuzzy_suggest(search_text) order by distance limit 1;
  IF type = 'ACTOR' THEN
    RAISE NOTICE 'Returning other movies % acts in',key;
    RETURN QUERY (
      SELECT *
      FROM movie_by_actor( key)
    );
    
  ELSIF type = 'MOVIE' THEN
    RAISE NOTICE 'Returning similar movies by Genre for %',key;
    RETURN QUERY (
      SELECT *
        FROM movie_by_genre( key )
    );

  ELSE
    RAISE NOTICE 'No Fuzzy Match - Check your spelling or try Google :) my db is too small';
  END IF;
  RETURN;
END;

$$ LANGUAGE plpgsql;
```

fuzzy_suggest(text) Uses simple levenshtein algorithm only to measure distance from actor and movie matches
- Returns a list of unordered matches and their similarity distance to the provided search term

**fuzzy_suggest Example Output:**
```
select * from fuzzy_suggest('Star Wars');
 suggested_keyword | keyword_type | distance 
-------------------+--------------+----------
 Star Wars         | MOVIE        |        1
 Sela Ward         | ACTOR        |        4
 Stan Haze         | ACTOR        |        4
```

**fuzzy_suggest Code:**
```
CREATE OR REPLACE FUNCTION fuzzy_suggest(search_keyword text)
RETURNS TABLE (suggested_keyword text, keyword_type text, distance integer) AS $$

DECLARE
  fuzzy_int integer;
  matched_type text;

BEGIN
  fuzzy_int = 1;
  matched_type = 'MOVIE';

  FOR fuzzy_int IN 1..10 LOOP
    IF (SELECT count (*) FROM movies WHERE levenshtein(lower(title), lower(search_keyword)) <= fuzzy_int) > 0 THEN
      -- RAISE NOTICE 'Movie matched at a distance of %',fuzzy_int;
      
      RETURN QUERY (
        SELECT title, matched_type, fuzzy_int FROM movies WHERE levenshtein(lower(title), lower(search_keyword)) <= fuzzy_int
      );
      
      EXIT;
    
    END IF;
  END LOOP;

  matched_type = 'ACTOR';
  -- fuzzy_int = 1;
  FOR fuzzy_int IN 1..10 LOOP
    IF (SELECT count (*) FROM actors WHERE levenshtein(lower(name), lower(search_keyword)) <= fuzzy_int) > 0 THEN
      -- RAISE NOTICE 'Actor matched at a distance of %',fuzzy_int;
      
      RETURN QUERY (
        SELECT name, matched_type, fuzzy_int FROM actors WHERE levenshtein(lower(name), lower(search_keyword)) <= fuzzy_int
      );
      
      EXIT;
 
    END IF;
  END LOOP;

END;

$$ LANGUAGE plpgsql;
```


movie_by_actor( text ) Returns a list of movies acted in by an exact match actor:

**movie_by_actor Example Output:**
```
book=# select * from movie_by_actor('Bruce Willis');
      top_5_titles      
------------------------
 In Country
 Mortal Thoughts
 Billy Bathgate
 Breakfast of Champions
 The Story of Us
```

**movie_by_actor Code:**
```
CREATE OR REPLACE FUNCTION movie_by_actor( search_actor text )
RETURNS TABLE (top_5_titles_actor text) AS $$

BEGIN
  RETURN QUERY (
  
    SELECT title
      FROM movies NATURAL JOIN movies_actors NATURAL JOIN actors WHERE name = search_actor;
      LIMIT 5
  );
END;

$$ LANGUAGE plpgsql;
```


movie_by_genre( text ) Returns a list of movies of a similar genre starting with an exact match movie using a 5x18 cube:

**movie_by_genre Example Output:**
```
select * from movie_by_genre('Star Wars');
                  top_5_titles                  
------------------------------------------------
 Star Wars: Episode V - The Empire Strikes Back
 Avatar
 Explorers
 Krull
 E.T. The Extra-Terrestrial
```

**movie_by_genre Code:**
```
CREATE OR REPLACE FUNCTION movie_by_genre( search_title text )
RETURNS TABLE (top_5_titles_genre text) AS $$

BEGIN
  RETURN QUERY (
    SELECT m.title
      FROM movies m, (SELECT genre, title FROM movies WHERE title = search_title) s WHERE cube_enlarge(s.genre, 5, 18) @> m.genre AND s.title <> m.title
      ORDER BY cube_distance(m.genre, s.genre)
      LIMIT 5
  );
END;

$$ LANGUAGE plpgsql;
```

#### 2. Expand the movies database to track user comments and extract keywords (minus English stopwords). Cross-reference these keywords with actors’ last names, and try to find the most talked about actors.
