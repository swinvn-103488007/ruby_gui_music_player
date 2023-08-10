
require 'gosu'
 
module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

GENRE = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

class Track
  attr_accessor :title, :location
  def initialize(title, location)
      @title = title
      @location = location
  end
end
   
class Album
  attr_accessor :id, :artist, :title, :genre, :cover_img, :tracks
  def initialize(id, artist, title, genre, cover_img,tracks)
    @id = id
    @artist = artist
    @title = title
    @genre = genre
    @cover_img = cover_img
    @tracks = tracks
  end
end


def read_tracks(music_library, tracks)
  song_title = music_library.gets
  song_location = music_library.gets.chomp
  track = Track.new(song_title, song_location)
  tracks << track
  return tracks
end

def read_album(music_library, num_of_alb)
  i = 0
  albums = []
  while i < num_of_alb
    alb_id = music_library.gets.to_i
    artist = music_library.gets
    title = music_library.gets
    genre = music_library.gets.to_i
    cover_img = music_library.gets.chomp
    num_of_song = music_library.gets.to_i
    j = 0
    tracks = []
    while j < num_of_song
      tracks = read_tracks(music_library, tracks)
      j += 1
    end
    album = Album.new(alb_id, artist, title, genre, cover_img,tracks)
    albums << album
    i += 1
  end
  return albums
end

def read_music_lib(music_library)
  num_of_alb = music_library.gets.to_i
  albums = read_album(music_library, num_of_alb)
  return albums
end

def print_lib_detail(albums)
  puts("\nList of albums:")
  i = 0
  while i < albums.length
    puts("\n#{i + 1}) " + "#{albums[i].title}")
    puts("Artist: " + "#{albums[i].artist}")
    puts("Genre: " + "#{GENRE[albums[i].genre]}")
    puts("Cover Image: " + "#{albums[i].cover_img}")
    puts("List of song: ")
    j = 0
    while (j < albums[i].tracks.length)
      puts("#{j + 1} - " + "#{albums[i].tracks[j].title}")
      puts("#{albums[i].tracks[j].location}")
      j += 1
    end
    puts ("\n")
    i += 1
  end
end

def search_track(albs, searching_track)
  i = 0
  while i < albs.length
    j = 0
    while j < albs[i].tracks.length
      if searching_track == albs[i].tracks[j].title.chomp
        puts("Found track: " + albs[i].tracks[j].title.chomp)
        puts("Album: " + albs[i].title.chomp)
        puts("Artist: " + albs[i].artist.chomp)
        track_found = 1
        return albs[i].tracks[j], albs[i]
      else
        track_found = -1
      end  
      j += 1
    end
    i += 1
  end
  if track_found == -1
    puts("No results found.")
    puts("Please check your song name again.")
    return track_found
  end
end

def main() 
  music_library = File.new("music_lib.txt", "r")
  albums = read_music_lib(music_library)  # read in a file - a music library 
  puts("Enter tracks you want to search: ")
  searching_track = gets
  search_track(albums, searching_track)
end