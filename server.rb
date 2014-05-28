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

def actors_data
  db_connection do |conn|
    @actors = conn.exec('SELECT actors.name FROM actors ORDER BY actors.name').to_a
  end
end

def movies_data
  db_connection do |conn|
    @movies = conn.exec('SELECT movies.title, movies.year,
    movies.rating, genres.name AS genre, studios.name AS studio_name
    FROM movies
    JOIN genres ON movies.genre_id = genres.id
    LEFT OUTER JOIN studios ON movies.studio_id = studios.id
    ORDER BY movies.title').to_a
  end
end


get '/actors' do

  @actors_data = actors_data

erb :'actors/index'
end

get '/movies' do

  @movies_data = movies_data
erb :'movies/index'
end
