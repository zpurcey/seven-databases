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

DELETE FROM temp_table
IF input text is closer to an actors name than a movie name THEN
  INSERT INTO temp_table [values from top5 movies cube search of actors (STORED PROC)]
ELSE
  INSERT INTO temp_table [values from top5 movies cube search of movie genres (STORED PROC)]

RETURN:
SELECT * FROM temp_table

  drop table top5_movies;
  

CREATE OR REPLACE FUNCTION movie_genuius( search_text text, fuzzy_int integer )
RETURNS TABLE (top_5_titles text) AS $$

BEGIN
  IF (SELECT COUNT (*) FROM actors WHERE levenshtein(lower(name), lower(search_text)) <= fuzzy_int) > 0 THEN
  RAISE NOTICE 'Best match as actor - generating results:';
  RETURN QUERY (
  
      SELECT *
        FROM movie_by_actor( search_text )
    );
  ELSIF (SELECT COUNT (*) FROM movies WHERE levenshtein(lower(title), lower(search_text)) <= fuzzy_int) > 0 THEN
  RAISE NOTICE 'Best match as Movie Title - generating results:';
    RETURN QUERY (
      SELECT *
        FROM movie_by_genre( search_text )
    );
  ELSE
    RAISE NOTICE 'No Fuzzy Match - try increasing fuzzy_int (accuracy) argument';
  END IF;
END;

$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION movie_by_actor( search_actor text )
RETURNS TABLE (top_5_titles_actor text) AS $$

BEGIN
  RETURN QUERY (
  
    SELECT title
      FROM movies NATURAL JOIN movies_actors NATURAL JOIN actors WHERE metaphone(name, 6) = metaphone(search_actor, 6)
      LIMIT 5
  );
END;

$$ LANGUAGE plpgsql;

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
CREATE OR REPLACE FUNCTION movie_genuius( in_title text, in_actor text )
RETURNS boolean AS $$
DECLARE
  did_insert boolean := false;
  found_count integer;
  the_venue_id integer;
BEGIN
  SELECT venue_id INTO the_venue_id
  FROM venues v
  WHERE v.postal_code=postal AND v.country_code=country AND v.name ILIKE venue LIMIT 1;
  IF the_venue_id IS NULL THEN
    INSERT INTO venues (name, postal_code, country_code) VALUES (venue, postal, country)
    RETURNING venue_id INTO the_venue_id;
    did_insert := true;
  END IF;
  RAISE NOTICE 'Venue found %', the_venue_id;
  INSERT INTO events (title, starts, ends, venue_id)
  VALUES (title, starts, ends, the_venue_id);
  
  RETURN did_insert;
END;
$$ LANGUAGE plpgsql;
```

#### 2. Expand the movies database to track user comments and extract keywords (minus English stopwords). Cross-reference these keywords with actors’ last names, and try to find the most talked about actors.
