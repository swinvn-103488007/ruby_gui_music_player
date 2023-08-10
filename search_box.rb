require 'rubygems'
require 'gosu'

module ZOrder
    BACKGROUND, PLAYER, UI = *0..2
end

# source I use to draw the search box and process text input:
# https://gist.github.com/t0dd/7bc1cbb84b05b55af0d07ebb59618640

class TextField < Gosu::TextInput
    # Some constants that define our appearance.
    INACTIVE_BOX_COLOR  = Gosu::Color::rgb(255,255,255)
    INACTIVE_TEXT_COLOR = Gosu::Color::BLACK
    ACTIVE_BOX_COLOR = Gosu::Color::rgb(30,30,30)
    ACTIVE_TEXT_COLOR = Gosu::Color::WHITE
    CARET_COLOR     = Gosu::Color::WHITE
    PADDING = 5
    
    attr_accessor :x, :y, :active
    
    def initialize(window, font, x, y)
      # TextInput's constructor doesn't expect any arguments.
      super()
      
      @window, @font, @x, @y = window, font, x, y
      @active = false 
      # Start with @inactive_text.
      @inactive_text = "Click to search songs"
    end
    
    # Example filter method. You can truncate the text to employ a length limit (watch out
    # with Ruby 1.8 and UTF-8!), limit the text to certain characters etc.
    
    def draw_box
      # Depending on whether this is the currently selected input or not, change the
      # background's color.
      if @active == true then
        background_color = ACTIVE_BOX_COLOR
      else
        background_color = INACTIVE_BOX_COLOR
      end

      @window.draw_rect(x - PADDING, y - PADDING, 350,25, background_color, ZOrder::BACKGROUND, mode =:default)
      
      # Calculate the position of the caret and the selection start.
      pos_x = x + @font.text_width(self.text[0...self.caret_pos])
      sel_x = x + @font.text_width(self.text[0...self.selection_start])
      
      # Draw the selection background, if any; if not, sel_x and pos_x will be
      # the same value, making this quad empty.

  
      # Draw the caret; again, only if this is the currently selected field.
      if @active == true then
        @window.draw_line(pos_x, y,          CARET_COLOR,
                          pos_x, y + height, CARET_COLOR, 0)
      end
  
      # Finally, draw the text itself!
      if @active == true then
        @font.draw_text(self.text, x, y,ZOrder::UI, 1.0, 1.0, ACTIVE_TEXT_COLOR)
      else
        @font.draw_text(@inactive_text, x, y,ZOrder::UI, 1.0, 1.0, INACTIVE_TEXT_COLOR)
      end
    end
    
  def box_selected?(mouse_x,mouse_y)
    if (mouse_x >= 5 && mouse_x <= 355 && mouse_y >= 300 and mouse_y <= 325) == true
      true
    else
      false
    end
  end
    # This text field grows with the text that's being entered.
    # (Usually one would use clip_to and scroll around on the text field.)
    def width
      @font.text_width(self.text)
    end
    
    def height
      @font.height
    end
    
    # Tries to move the caret to the position specifies by mouse_x
  def move_caret(mouse_x)
    # Test character by character
    1.upto(self.text.length) do |i|
    if mouse_x < x + @font.text_width(text[0...i]) then
      self.caret_pos = self.selection_start = i - 1;
      end
    end
      # Default case: user must have clicked the right edge
    self.caret_pos = self.selection_start = self.text.length
  end
end