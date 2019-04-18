require "sinatra"
require "sinatra/reloader" if development?
require "sqlite3"

DB = SQLite3::Database.new(File.join(File.dirname(__FILE__), 'db/jukebox.sqlite'))

get "/" do
  # TODO: Gather all artists to be displayed on home page
  query = <<-SQL
  SELECT id, name FROM artists
  SQL

  @artists = DB.execute(query)

  erb :home # Will render views/home.erb file (embedded in layout.erb)
end

# 1. Create an artist page with all the albums. Display genres as well
get "/artists/:id" do
  query = <<-SQL
  SELECT artists.name, albums.title, genres.name, albums.id
  FROM albums
  JOIN tracks ON tracks.album_id = albums.id
  JOIN genres ON genres.id = tracks.genre_id
  JOIN artists ON artists.id = albums.artist_id
  WHERE albums.artist_id = "#{@params[:id]}"
  GROUP BY albums.title
  SQL
  @albums = DB.execute(query).map do |album|
    {
      artist_name: album[0],
      album_title: album[1],
      genre_name: album[2],
      id: album[3]
    }
  end
  erb :artist
end

# 2. Create an album pages with all the tracks
get "/albums/:id" do
  query = <<-SQL
  SELECT albums.title, tracks.name, tracks.id
  FROM tracks
  JOIN albums ON tracks.album_id = albums.id
  WHERE albums.id = "#{@params[:id]}"
  SQL
  @tracks = DB.execute(query).map do |track|
    {
      album_title: track[0],
      track_name: track[1],
      id: track[2]
    }
  end
  erb :album
end
# 3. Create a track page with all the track info
get "/tracks/:id" do
  query = <<-SQL
  SELECT tracks.name, artists.name, albums.title, genres.name, tracks.milliseconds
  FROM tracks
  JOIN albums ON tracks.album_id = albums.id
  JOIN artists ON artists.id = albums.artist_id
  JOIN genres ON genres.id = tracks.genre_id
  WHERE tracks.id = "#{@params[:id]}"
  SQL
  @track_info = DB.execute(query)[0]
  erb :track
end



