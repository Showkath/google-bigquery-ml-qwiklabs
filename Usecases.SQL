#1) The subquery (MOVIE_CRITERIA) selects a movie with a rating higher than 7 and uses that information to generate a prompt for ML.GENERATE_TEXT.

SELECT
  generated_text,
  safety_attributes,
  * EXCEPT (ml_generate_text_result)
FROM
  ML.GENERATE_TEXT(
    MODEL `qwiklabs-gcp-01-f3e2760ed1a9.movie_insights.model_rating_by_runtime_genre`,
    (
      SELECT
        CONCAT('GENERATE A MOVIE DESCRIPTION FOR A ', genre, ' MOVIE WITH A RATING HIGHER THAN ', CAST(rating AS STRING), ' AND A RUNTIME AROUND ', CAST(runtime AS STRING), ' MINUTES.') AS prompt
      FROM (
        SELECT
          genre,
          rating,
          runtime
        FROM
          `qwiklabs-gcp-01-f3e2760ed1a9.movie_insights.movie_data`
        WHERE
          rating > 7
        LIMIT
          1
      ) AS MOVIE_CRITERIA
    ),
    STRUCT(
      0.5 AS temperature,
      150 AS max_output_tokens
    )
  );

#2) Generating movie recommendations based on certain criteria like query generates movie recommendations for fans of a specific genre with a rating higher than 7.5

SELECT
  ml_generate_text_result['predictions'][0]['content'] AS generated_text,
  ml_generate_text_result['predictions'][0]['safetyAttributes']
    AS safety_attributes,
  * EXCEPT (ml_generate_text_result)
FROM
  ML.GENERATE_TEXT(
    MODEL `movie_insights.recommendation_model`,
    (
      SELECT
        CONCAT('SUGGEST A MOVIE RECOMMENDATION FOR FANS OF ', genre, ' GENRE AND WITH A RATING HIGHER THAN 7.5: ', additional_criteria) AS prompt
      FROM (
        SELECT
          REPLACE(STRING_AGG( CONCAT('Fans of ', genre, ' movies with a rating higher than 7.5 will enjoy ', name, ' starring ', star, ' and produced by ', company, '.'), ', ') AS additional_criteria
        FROM
          `movie_insights.movie_data`
        WHERE
          genre = 'Action'
          AND CAST(rating AS FLOAT64) > 7.5
        LIMIT
          50) ) AS MOVIE_CRITERIA
    ),
    STRUCT(
      0.4 AS temperature,
      120 AS max_output_tokens));


      

      #3) ML.GENERATE_TEXT, focusing on generating movie-related content, specifically plot summaries:

  -- The query generates plot summaries for mystery movies released after 2023. 
 --We can customize the genre, release year, and other criteria based on your preferences or data


 SELECT
  ml_generate_text_result['predictions'][0]['content'] AS generated_text,
  ml_generate_text_result['predictions'][0]['safetyAttributes']
    AS safety_attributes,
  * EXCEPT (ml_generate_text_result)
FROM
  ML.GENERATE_TEXT(
    MODEL `movie_insights.plot_summary_model`,
    (
      SELECT
        CONCAT('GENERATE A PLOT SUMMARY FOR A MYSTERY MOVIE RELEASED AFTER 2010: ', additional_criteria) AS prompt
      FROM (
        SELECT
          REPLACE(STRING_AGG( CONCAT('A gripping mystery unfolds in ', name, ', a movie released in ', release_year, ', featuring ', star, ' and directed by ', director, '.'), ', ') AS additional_criteria
        FROM
          `movie_insights.movie_data`
        WHERE
          genre = 'Mystery'
          AND release_year > 2010
        LIMIT
          50) ) AS MYSTERY_MOVIES
    ),
    STRUCT(
      0.3 AS temperature,
      150 AS max_output_tokens));



#4  The query generates interesting trivia about movies released after 2000 that have received some accolades
[ interesting facts, anecdotes, or details related to the production, cast, or reception of a film. Trivia is often used to engage audiences and provide additional insights or fun facts about a particular subject]
["Accolades" refer to expressions of approval or praise, typically given as an award or honor. In the context of movies, accolades could include various forms of recognition or achievements, such as winning prestigious awards like the Oscars, Golden Globes,]

SELECT
  ml_generate_text_result['predictions'][0]['content'] AS generated_text,
  ml_generate_text_result['predictions'][0]['safetyAttributes']
    AS safety_attributes,
  * EXCEPT (ml_generate_text_result)
FROM
  ML.GENERATE_TEXT(
    MODEL `movie_insights.trivia_model`,
    (
      SELECT
        CONCAT('SHARE AN INTERESTING MOVIE TRIVIA ABOUT ', name, ': ', additional_criteria) AS prompt
      FROM (
        SELECT
          REPLACE(STRING_AGG( CONCAT('Did you know that ', name, ' achieved ', accolade, ' and was the ', position, ' highest-grossing movie in ', release_year, '?'), ', ') AS additional_criteria
        FROM
          `movie_insights.movie_data`
        WHERE
          accolade IS NOT NULL
          AND release_year > 2000
        LIMIT
          50) ) AS MOVIE_TRIVIA
    ),
    STRUCT(
      0.4 AS temperature,
      120 AS max_output_tokens));

      
      -----

      SELECT
  generated_text,
  safety_attributes,
  * EXCEPT (ml_generate_text_result)
FROM
  ML.GENERATE_TEXT(
    MODEL `movie_insights.trivia_model`,
    (
      SELECT
        CONCAT('SHARE AN INTERESTING MOVIE TRIVIA ABOUT ', name, ': ', additional_criteria) AS prompt
      FROM (
        SELECT
          REPLACE(STRING_AGG( CONCAT('Did you know that ', name, ' achieved ', accolade, ' and was the ', position, ' highest-grossing movie in ', release_year, '?'), ', '), ',', '.') AS additional_criteria
        FROM
          `movie_insights.movie_data`
        WHERE
          accolade IS NOT NULL
          AND release_year > 2000
        LIMIT
          50
      ) AS MOVIE_TRIVIA
    ),
    STRUCT(
      0.4 AS temperature,
      120 AS max_output_tokens
    )
  );
