require 'gosu'
require 'rubygems'

song = Gosu::Song.new("music_lib/HowDeepIsYourLove.mp3")
song.play()
puts(Gosu::Song::current_song)
a = Gosu::Window.new(800, 600)
a.show()