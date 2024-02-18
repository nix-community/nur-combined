{ pkgs
, user
, ...
}: {
  programs.kitty = {
    enable = false;
    font = {
      name = "Maple Mono";
      size =
        if user == "elen" then 13.0 else 15;
    };
    settings = {
      background_opacity = "0.92";
      confirm_os_window_close = "0";
    };

    # keybindings = {
    #   "cmd+t" = "new_tab";
    #   "cmd+j" = "next_tab";
    #   "cmd+k" = "previous_tab";
    #   "cmd+w" = "close_tab";
    # };

    extraConfig = ''
      shell ${pkgs.fish}/bin/fish -i
      disable_ligatures never
      cursor_blink_interval 0.3
    
      # The basic colors
      window_padding_width 4
      foreground              #CAD3F5
      background              #0F0D0E
      #24273A
      selection_foreground    #24273A
      selection_background    #F4DBD6
    
      # Cursor colors
      cursor                  #F4DBD6
      cursor_text_color       #24273A
    
      # URL underline color when hovering with mouse
      url_color               #F4DBD6
    
      # Kitty window border colors
      active_border_color     #B7BDF8
      inactive_border_color   #6E738D
      bell_border_color       #EED49F
    
      # OS Window titlebar colors
      wayland_titlebar_color system
      macos_titlebar_color system
    
      hide_window_decorations yes
      # Tab bar colors
      active_tab_foreground   #181926
      active_tab_background   #C6A0F6
      inactive_tab_foreground #CAD3F5
      inactive_tab_background #1E2030
      tab_bar_background      #181926
    
      # Colors for marks (marked text in the terminal)
      mark1_foreground #24273A
      mark1_background #B7BDF8
      mark2_foreground #24273A
      mark2_background #C6A0F6
      mark3_foreground #24273A
      mark3_background #7DC4E4
    
      # The 16 terminal colors
    
      # black
      color0 #494D64
      color8 #5B6078
    
      # red
      color1 #ED8796
      color9 #ED8796
    
      # green
      color2  #A6DA95
      color10 #A6DA95
    
      # yellow
      color3  #EED49F
      color11 #EED49F
    
      # blue
      color4  #8AADF4
      color12 #8AADF4
    
      # magenta
      color5  #F5BDE6
      color13 #F5BDE6
    
      # cyan
      color6  #8BD5CA
      color14 #8BD5CA
    
      # white
      color7  #B8C0E0
      color15 #A5ADCB
    
      protocol file
      ext js,jsx,ts,tsx,rs,c,cpp,cc,json,toml,kt,yaml,yml,sh,fish,nu,nix,lock
      action launch --type=overlay $EDITOR $FILE_PATH
    
      protocol file
      mime text/plain
      action launch --type=overlay $EDITOR $FILE_PATH
    
      # Open directories
      protocol file
      mime inode/directory
      action launch --cwd $FILE_PATH
    
      # Open executable file
      protocol file
      mime inode/executable,application/vnd.microsoft.portable-executable
      action launch --hold --type=overlay $FILE_PATH
    
      # Open text files without fragments in the editor
      protocol file
      mime text/*
      action launch --type=overlay $EDITOR $FILE_PATH
    
      # Open image files with icat
      protocol file
      mime image/*
      action launch --type=overlay kitty +kitten icat --hold $FILE_PATH
    
      # Open video files with vlc
      protocol file
      mime video/*
      action launch --type=os-window vlc $FILE_PATH
    
      # Open ssh URLs with ssh command
      protocol ssh
      action launch --type=overlay ssh $URL
    '';
  };
}
