require 'pg'
require 'sinatra'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')

    yield(connection)

  ensure
    connection.close
  end
end

def actor_names_data
  query = 'SELECT actors.name, actors.id FROM actors
           ORDER BY actors.name'
  db_connection do |conn|
    actors = conn.exec(query)
  end
end

def actor_profile_data

  query = 'SELECT actors.id, actors.name, movies.title, cast_members.character, movies.id AS movies_id
           FROM cast_members
           JOIN movies ON cast_members.movie_id = movies.id
           JOIN actors ON cast_members.actor_id = actors.id
           ORDER BY movies.title'

  db_connection do |conn|
    actors = conn.exec(query)
  end
end

def movies_data
  query = 'SELECT movies.title, movies.year, movies.id,
           movies.rating, genres.name AS genre, studios.name AS studio_name
           FROM movies
           JOIN genres ON movies.genre_id = genres.id
           LEFT OUTER JOIN studios ON movies.studio_id = studios.id
           ORDER BY movies.title'
  db_connection do |conn|
    movies = conn.exec(query)
  end
end

def movie_info
  query = 'SELECT movies.title AS title, genres.name AS genre,
           studios.name AS studio, actors.name AS name,
           cast_members.character, movies.id, actors.id AS actors_id
           FROM movies
           JOIN genres ON movies.genre_id = genres.id
           JOIN cast_members ON cast_members.movie_id = movies.id
           JOIN actors ON cast_members.actor_id = actors.id
           LEFT OUTER JOIN studios ON movies.studio_id = studios.id'
  db_connection do |conn|
    movies = conn.exec(query)
  end
end

get '/actors' do

  @actor_names_data = actor_names_data
  erb :'actors/index'
end

get '/actors/:id' do
  @actor_profile_data = actor_profile_data

  @actor_profile_data.each do |actor|
    if actor["id"] == params[:id]
      @actor_profile = actor
    end
  end

  erb :'actors/show'
end

get '/movies' do

  @movies_data = movies_data

  erb :'movies/index'
end

get '/movies/:id' do
  @movie_info = movie_info

  @movie_info.each do |movie|
    if movie["id"] == params[:id]
      @movie_details = movie
    end
  end

  erb :'movies/show'
end
