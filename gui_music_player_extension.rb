require 'rubygems'
require 'gosu'
require './alb_functions.rb'
require './search_box.rb'

WINDOW_BG_COLOR = Gosu::Color::rgb(12,12,12)
DEFAULT_TEXT_COLOR = Gosu::Color::rgb(255,255,255)
MUSIC_PLAYING_COLOR = Gosu::Color::rgb(0,255,0)

class MusicPlayer < Gosu::Window
  
  #draw the cover image of each album on the screen
  def draw_alb_imgs(displaying_alb_index)
    i = 0
    while i < @albs.length
      @alb_titles[i] = Gosu::Image.from_text(@albs[i].title.to_s.upcase,18,{:bold => true, :width => 175, :align => :center})
      i += 1
    end
    i = 0
    while i < 4
      @cover_imgs[displaying_alb_index].draw(@cover_img_x[i],@cover_img_y,ZOrder::UI)
      if @playing_alb_title == @albs[displaying_alb_index].title
        @text_color = MUSIC_PLAYING_COLOR
      else
        @text_color = DEFAULT_TEXT_COLOR
      end
      @alb_titles[displaying_alb_index].draw(@cover_img_x[i],225,ZOrder::UI,1,1, @text_color)
      displaying_alb_index += 1
      i += 1
    end
    @text_color = DEFAULT_TEXT_COLOR
  end

  #draw media button
  def draw_btns()
    @backward_btn.draw(@media_btns_x[0], @media_btn_y,ZOrder::UI)
    if (Gosu::Song.current_song == nil) || (Gosu::Song.current_song.paused? == true)
      @play_btn.draw(@media_btns_x[1], @media_btn_y,ZOrder::UI)
    else
      @pause_btn.draw(@media_btns_x[1], @media_btn_y,ZOrder::UI)
    end
    @stop_btn.draw(@media_btns_x[2], @media_btn_y,ZOrder::UI)
    @forward_btn.draw(@media_btns_x[3], @media_btn_y,ZOrder::UI)
    @next_page_btn.draw(920,120,ZOrder::UI)
    @previous_page_btn.draw(20,120,ZOrder::UI)
    @spotify_icon.draw(400,300,ZOrder::UI)
    if @shuffle == false
    @shuffle_off_btn.draw(@media_btns_x[4],@media_btn_y,ZOrder::UI)
    else
    @shuffle_on_btn.draw(@media_btns_x[4],@media_btn_y,ZOrder::UI)
    end
  end

  #draw the title of the album that is selected to play
  def draw_selected_alb()
    i = 0
    displaying_tracks = []
    while i < @albs[@playing_alb_index].tracks.length
      displaying_track = Gosu::Image.from_text("#{i + 1} - #{@albs[@playing_alb_index].tracks[i].title.to_s}",18,{:width => 350,:align => :left})
      displaying_tracks << displaying_track 
      i += 1
    end 
    displaying_title = Gosu::Image.from_text(@albs[@playing_alb_index].title.to_s,20,{:bold => true, :width => 350,:align => :left})
    displaying_artist = Gosu::Image.from_text(@albs[@playing_alb_index].artist.to_s,18,{:width => 350,:align => :left})
    displaying_title.draw(650,300,ZOrder::UI,1,1,DEFAULT_TEXT_COLOR)
    displaying_artist.draw(650,330,ZOrder::UI,1,1,DEFAULT_TEXT_COLOR)
    i = 0
    while i < displaying_tracks.length
      if @albs[@playing_alb_index].tracks[i].title == @current_song_title
        @color = MUSIC_PLAYING_COLOR
      else
        @color = DEFAULT_TEXT_COLOR
      end
      displaying_tracks[i].draw(650,@tracks_y[i],ZOrder::UI,1,1,@color)
      i += 1
    end
    @color = DEFAULT_TEXT_COLOR
  end

  #draw the result of the search
  def draw_search_results(search_results)
    if search_results == - 1
      Gosu::Image.from_text("Search Result", 20, {:bold => true, :width =>350}).draw(5,330,ZOrder::UI,1,1,DEFAULT_TEXT_COLOR)
      Gosu::Font.new(16).draw_text("No song found. Please check you song name again.", 5, @tracks_y[0], ZOrder::UI,1,1,DEFAULT_TEXT_COLOR)
    end  
    if search_results != -1
      track_found = search_results[0]
      alb_found = search_results[1]
      Gosu::Image.from_text("Search Result", 20, {:bold => true, :width =>350}).draw(5,330,ZOrder::UI,1,1,DEFAULT_TEXT_COLOR)
      font = Gosu::Font.new(16)
      Gosu::Image.from_text("Song Found:", 16, {:bold => true}).draw(5,@tracks_y[0],ZOrder::UI,1,1,DEFAULT_TEXT_COLOR)
      font.draw_text(track_found.title,5, @tracks_y[1],ZOrder::UI,1,1,DEFAULT_TEXT_COLOR)
      Gosu::Image.from_text("Album", 16, {:bold => true}).draw(5,@tracks_y[2],ZOrder::UI,1,1,DEFAULT_TEXT_COLOR)
      font.draw_text(alb_found.title,5, @tracks_y[3],ZOrder::UI,1,1,DEFAULT_TEXT_COLOR)
      Gosu::Image.from_text("Artist", 16, {:bold => true}).draw(5,@tracks_y[4],ZOrder::UI,1,1,DEFAULT_TEXT_COLOR)
      font.draw_text(alb_found.artist,5, @tracks_y[5],ZOrder::UI,1,1,DEFAULT_TEXT_COLOR)
    end
  end

  #change the page of album to the previous
  def previous_page()
    if @displaying_alb_index == 0
      @displaying_alb_index += 0
      @current_song_title = @current_song_title
    else
      @displaying_alb_index -= 4
      @current_song_title = @current_song_title
    end
  end

  #change the page of the album to the next
  def next_page()
    if @displaying_alb_index == (@albs.length - 4)
      @displaying_alb_index += 0 
      @current_song_title = @current_song_title
    else
      @displaying_alb_index += 4
      @current_song_title = @current_song_title
    end
  end

  #check out whether user clicked on the search box
  def search_result_clicked(mouse_x,mouse_y)
    if mouse_x >= 5 && mouse_x <= 350 && mouse_y >= @tracks_y[1] && mouse_y <= @tracks_y[1] + 16
      return "song_found_clicked"
    end
    if mouse_x >= 5 && mouse_x <= 350 && mouse_y >= @tracks_y[3] && mouse_y <= @tracks_y[3] + 16
      return "album_found_clicked"
    end
  end

  #check out whether user clicked on the cover image of any album
  def cover_img_clicked(mouse_x, mouse_y)
    if (mouse_x >= @cover_img_x[0] && mouse_x <= (@cover_img_x[0] + 175) && mouse_y >= @cover_img_y && mouse_y <= @cover_img_y + 175)
      cover_img_clicked = 0
    elsif (mouse_x >= @cover_img_x[1] && mouse_x <= (@cover_img_x[1] + 175) && mouse_y >= @cover_img_y && mouse_y <= @cover_img_y + 175)
      cover_img_clicked = 1
    elsif (mouse_x >= @cover_img_x[2] && mouse_x <= (@cover_img_x[2] + 175) && mouse_y >= @cover_img_y && mouse_y <= @cover_img_y + 175)
      cover_img_clicked = 2
    elsif (mouse_x >= @cover_img_x[3] && mouse_x <= (@cover_img_x[3] + 175) && mouse_y >= @cover_img_y && mouse_y <= @cover_img_y + 175)
      cover_img_clicked = 3
    else
      cover_img_clicked = nil
    end 
    cover_img_clicked
  end

  #check out whether user clicked on the any media button
  def btn_clicked(mouse_x, mouse_y)
    if mouse_x >= @media_btns_x[0] && (mouse_x <= (@media_btns_x[0] + 48)) && mouse_y >= @media_btn_y && (mouse_y <= (@media_btn_y + 48))
      btn_clicked = "backward"
    elsif mouse_x >= @media_btns_x[1] && (mouse_x <= (@media_btns_x[1] + 48)) && mouse_y >= @media_btn_y && (mouse_y <= (@media_btn_y + 48))
      btn_clicked = "play_or_pause"
    elsif mouse_x >= @media_btns_x[2] && (mouse_x <= (@media_btns_x[2] + 48)) && mouse_y >= @media_btn_y && (mouse_y <= (@media_btn_y + 48))
      btn_clicked = "stop"
    elsif mouse_x >= @media_btns_x[3] && (mouse_x <= (@media_btns_x[3] + 48)) && mouse_y >= @media_btn_y && (mouse_y <= (@media_btn_y + 48))
      btn_clicked = "forward"
    elsif mouse_x >= @media_btns_x[4] && (mouse_x <= (@media_btns_x[4] + 48)) && mouse_y >= @media_btn_y && (mouse_y <= (@media_btn_y + 48))
      btn_clicked = "shuffle"
    else
      btn_clicked = nil
    end  
    return btn_clicked
  end

  #check out whether user clicked on the title of any displaying song
  def song_title_clicked(mouse_x, mouse_y)
    i = 0
    while i < @tracks_y.length
      if mouse_x >= 650 && mouse_x <= 1000 && mouse_y >= @tracks_y[i] && mouse_y <= (@tracks_y[i] + 18)
        return i
      end
      i += 1
    end
    nil
  end

  #play the album which the cover image was clicked on 
  def play_selected_alb()
    @current_song_location = Gosu::Song::new(@albs[@playing_alb_index].tracks[@playing_track_index].location.chomp)
    @current_song_location.play()
  end

  #play the current song
  def play()
    Gosu::Song.current_song.play()
  end
  
  #pause the current song
  def pause()
    Gosu::Song.current_song.pause()
  end

  #set the current playing album to the start
  def back_to_start()
    @playing_track_index = 0
    @current_song_location = Gosu::Song::new(@albs[@playing_alb_index].tracks[@playing_track_index].location.chomp)
    @current_song_location.play()
    @current_song_location.pause()
    end

  #play the previous song in the album 
  def previous_song()
    if @playing_track_index == 0
      @playing_track_index = 1
    end
    @playing_track_index -= 1
    @current_song_location = Gosu::Song::new(@albs[@playing_alb_index].tracks[@playing_track_index].location.chomp)
    @current_song_location.play()
  end

  #play the next song in the album
  def next_song()
    if @playing_track_index >= (@albs[@playing_alb_index].tracks.length - 1) 
      @playing_track_index = -1
    end
    @playing_track_index += 1
    @current_song_location = Gosu::Song::new(@albs[@playing_alb_index].tracks[@playing_track_index].location.chomp)
    @current_song_location.play()
  end
  
  def initialize
    super(1000, 700, false)
    self.caption = "Fake Spotify"
    @alb_title_font = Gosu::Font.new(20)
    @track_font = Gosu::Font.new(18)
    music_lib = File.new("music_lib.txt", "r")
    @albs = read_music_lib(music_lib)

    i = 0
    @alb_titles = []  
    while i < @albs.length
      title = @albs[i].title
      @alb_titles << title
      i += 1
    end
    i = 0
    @cover_imgs = []
    while i < @albs.length
      cover_img = Gosu::Image.new("#{@albs[i].cover_img.chomp}")
      @cover_imgs << cover_img
      i += 1
    end
    @displaying_alb_index = 0
    @playing_track_index = 0
    @playing_alb = nil
    @shuffle = false
    @cover_img_x = [120, 315, 510, 705]
    @cover_img_y = 40
    @media_btns_x = [356, 414, 472, 530, 588]
    @media_btn_y = 512
    @tracks_x = 740
    @tracks_y = [370,395,420,445,470,495,520,545,570,595,620,645,670]
    font = Gosu::Font.new(16)
    @search_box = TextField.new(self, font, 10, 300)
    @previous_page_btn = Gosu::Image.new("images/previous_btn.png")
    @next_page_btn = Gosu::Image.new("images/next_btn.png") 
    @play_btn = Gosu::Image.new("images/play.png")
    @pause_btn = Gosu::Image.new("images/pause.png")
    @stop_btn = Gosu::Image.new("images/stop.png")
    @backward_btn = Gosu::Image.new("images/backward.png")
    @forward_btn = Gosu::Image.new("images/forward.png")
    @shuffle_off_btn = Gosu::Image.new("images/shuffle_off.png")
    @shuffle_on_btn = Gosu::Image.new("images/shuffle_on.png")
    @spotify_icon = Gosu::Image.new("images/spotify.png")
    @text_color = DEFAULT_TEXT_COLOR
    puts("Playing album:" + @playing_alb.to_s)
  end

  def draw
    Gosu.draw_rect(0,0,1000,700,WINDOW_BG_COLOR,ZOrder::BACKGROUND)
    draw_alb_imgs(@displaying_alb_index)
    draw_btns()
    @search_box.draw_box 
    if @playing_alb_index != nil
      draw_selected_alb()
    end
    if @search_results != nil && @search_box.text != ""
      draw_search_results(@search_results)
    end
  end

  def update
    if @playing_alb_index != nil && Gosu::Song.current_song == nil
      @playing_track_index += 1
      if @playing_track_index >= @albs[@playing_alb_index].tracks.length
        back_to_start()
      end
      @current_song_title = @albs[@playing_alb_index].tracks[@playing_track_index].title
      play_selected_alb()
    end
  end

  def button_down(id)
    case id
    when Gosu::MsLeft
      if (mouse_x >= 20 && mouse_x <= 80) && (mouse_y >= 120 && mouse_y <= 180)
        previous_page()
      elsif (mouse_x >= 920 && mouse_x <= 980) && (mouse_y >= 120 && mouse_y <= 180)
        next_page()
      end

      cover_img_clicked = cover_img_clicked(mouse_x, mouse_y)
      case cover_img_clicked
      when nil
        if @playing_alb_index == nil
          @playing_alb_index = nil
        elsif @playing_alb_index != nil
          @playing_alb_index += 0
        end  
      else
        @playing_alb_index = @displaying_alb_index + cover_img_clicked
        @playing_alb_title = @albs[@playing_alb_index].title
        puts("Playing album: " + "#{@playing_alb_title}")
        back_to_start()
        play_selected_alb()  
      end
 
      song_title_clicked = song_title_clicked(mouse_x,mouse_y)
      if @playing_alb_index != nil && song_title_clicked != nil
        if song_title_clicked < @albs[@playing_alb_index].tracks.length
          @playing_track_index = song_title_clicked
          @current_song_location = Gosu::Song.new(@albs[@playing_alb_index].tracks[@playing_track_index].location)
          @current_song_location.play()
        end
      end
      
      btn_clicked = btn_clicked(mouse_x,mouse_y)
      if @playing_alb_index != nil then
        case btn_clicked
        when "backward"
          previous_song()
        when "play_or_pause"
          if Gosu::Song.current_song.playing? == true
            pause()
          elsif Gosu::Song.current_song.paused? == true
            play()
          end
        when "stop"
          back_to_start()
        when "forward" 
          next_song()
        when "shuffle"
          if @shuffle == true
            @shuffle = false
          else
            @shuffle = true
          end
        end  
        if @playing_alb_index == nil 
          @current_song_title = ""
        else
          @current_song_title = @albs[@playing_alb_index].tracks[@playing_track_index].title
        end
      end

      box_selected = @search_box.box_selected?(mouse_x, mouse_y)
      if box_selected == true
        @search_box.active = true
        self.text_input = @search_box
        self.text_input.move_caret(mouse_x) unless self.text_input.nil?
      else
        @search_box.active = false
      end

      search_result_clicked = search_result_clicked(mouse_x, mouse_y)
      if @search_results != -1 && @search_results != nil
        if search_result_clicked == "song_found_clicked"
          song_found = @search_results[0]
          alb_found = @search_results[1]
          @playing_alb_index = alb_found.id - 1
          @playing_alb_title = alb_found.title
          @playing_track_index = alb_found.tracks.index(song_found) 
          @current_song_title = alb_found.tracks[@playing_track_index].title
          @current_song_location = Gosu::Song.new(@albs[@playing_alb_index].tracks[@playing_track_index].location)
          @current_song_location.play()
        elsif search_result_clicked == "album_found_clicked"
          song_found = @search_results[0]
          alb_found = @search_results[1]
          @playing_alb_index = alb_found.id - 1
          @playing_alb_title = @albs[@playing_alb_index].title
          @playing_track_index = 0
          @current_song_title = @albs[@playing_alb_index].tracks[@playing_track_index].title
          play_selected_alb()
        end
      end
      
    when Gosu::KB_ENTER
      if @search_box.active == true
        puts(box_selected.to_s)
        puts(@search_box.text)
        @search_results = search_track(@albs, @search_box.text.chomp)
      end
    end
  end

end

MusicPlayer.new.show