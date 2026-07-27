{ ... }:
{
  /*
	programs.rofi = {
		enable = true;
		theme = "Arc-Dark";
		extraConfig = {
			modi = "run,filebrowser";
			color-normal = "#1c2023, #919ba0, #1c2023, #a4a4a4, #1c2023";
			color-urgent = "argb:00000000, #f43753, argb:00000000, argb:00000000, #e29a49";
			color-active = "argb:00000000, #49bbfb, argb:00000000, argb:00000000, #e29a49";
			color-window = "#1c2023, #919ba0, #1c2023";
		};
	};
  */

  
  # credit https://github.com/lostMia/nixos-config/blob/f1654caf8572f25f9de9216cfe402995187f3c27/programs/rofi.nix
  home.file.".config/rofi/config.rasi".text = ''
    * {
      selected-normal-foreground:  #282a36;
      foreground:                  #f8f8f2;
      item-normal:                 #1e1e1e;
      item-alternative:            #222222;
      normal-foreground:           @foreground;
      alternate-normal-background: rgba ( 45, 48, 59, 1 % );
      red:                         rgba ( 220, 50, 47, 100 % );
      selected-urgent-foreground:  rgba ( 249, 249, 249, 100 % );
      blue:                        rgba ( 38, 139, 210, 100 % );
      urgent-foreground:           rgba ( 204, 102, 102, 100 % );
      alternate-urgent-background: rgba ( 75, 81, 96, 90 % );
      active-foreground:           rgba ( 101, 172, 255, 100 % );
      lightbg:                     rgba ( 238, 232, 213, 100 % );
      selected-active-foreground:  @foreground;
      alternate-active-background: rgba ( 45, 48, 59, 88 % );
      background:                  #1b1b1b;
      alternate-normal-foreground: @foreground;
      normal-background:           rgba ( 45, 48, 59, 1 % );
      lightfg:                     rgba ( 88, 104, 117, 100 % );
      selected-normal-background:  #f8f8f2;
      border-color:                #ff3060;
      spacing:                     10;
      separatorcolor:              rgba ( 45, 48, 59, 1 % );
      urgent-background:           rgba ( 45, 48, 59, 15 % );
      selected-urgent-background:  rgba ( 165, 66, 66, 100 % );
      alternate-urgent-foreground: @urgent-foreground;
      background-color:            rgba ( 0, 0, 0, 0 % );
      alternate-active-foreground: @active-foreground;
      active-background:           rgba ( 29, 31, 33, 17 % );
      selected-active-background:  rgba ( 26, 28, 35, 100 % );
    }

    configuration {
        font:				"HackNerdFont Regular 14";
        show-icons:				true;
        icon-theme:				"Tela circle purple dark";
        drun-display-format:		"{name}";
        scroll-method:			0;
        disable-history:			false;
        sidebar-mode:			false;
    }

    window {
        background-color: @background;
        border:           2;
        border-color:     @border-color;
        padding:          15;
        width:            500px;
    }
    listview {
        lines:                          12;
        columns:                        1;
    }
    mainbox {
        border:  0;
        padding: 0;
    }
    message {
        border:       2px 0px 0px ;
        border-color: @separatorcolor;
        padding:      1px ;
    }
    textbox {
        text-color: @foreground;
    }
    listview {
        fixed-height: 0;
        border:       8px 0px 0px ;
        border-color: @separatorcolor;
        spacing:      8px ;
        scrollbar:    false;
        padding:      2px 0px 0px ;
    }
    element {
        border: 1px;
        border-radius: 12px;
        border-color: #333333;
        padding: 4px ;
    }
    element-text {
        background-color: inherit;
        text-color:       inherit;
    }
    element.normal.normal {
        background-color: @item-normal;
        text-color:       @normal-foreground;
    }
    element.normal.urgent {
        background-color: @urgent-background;
        text-color:       @urgent-foreground;
    }
    element.normal.active {
        background-color: @active-background;
        text-color:       @active-foreground;
    }
    element.selected.normal {
        background-color: @selected-normal-background;
        text-color:       @selected-normal-foreground;
    }
    element.selected.urgent {
        background-color: @selected-urgent-background;
        text-color:       @selected-urgent-foreground;
    }
    element.selected.active {
        background-color: @selected-active-background;
        text-color:       @selected-active-foreground;
    }
    element.alternate.normal {
        background-color: @item-alternative;
        text-color:       @alternate-normal-foreground;
    }
    element.alternate.urgent {
        background-color: @alternate-urgent-background;
        text-color:       @alternate-urgent-foreground;
    }
    element.alternate.active {
        background-color: @alternate-active-background;
        text-color:       @alternate-active-foreground;
    }
    scrollbar {
        width:        4px ;
        border:       0;
        handle-color: @normal-foreground;
        handle-width: 8px ;
        padding:      0;
    }
    mode-switcher {
        border:       2px 0px 0px ;
        border-color: @separatorcolor;
    }
    button {
        spacing:    0;
        text-color: @normal-foreground;
    }
    button.selected {
        background-color: @selected-normal-background;
        text-color:       @selected-normal-foreground;
    }
    inputbar {
        spacing:    0;
        text-color: @normal-foreground;
        padding:    1px ;
    }
    case-indicator {
        spacing:    0;
        text-color: @normal-foreground;
    }
    entry {
        spacing:    0;
        text-color: @normal-foreground;
    }
    prompt {
        spacing:    0;
        text-color: @normal-foreground;
    }
    inputbar {
        children:   [ prompt,textbox-prompt-colon,entry,case-indicator ];
    }
    textbox-prompt-colon {
        expand:     false;
        str:        " ";
        margin:     0px 0.3em 0em 0em ;
        text-color: @normal-foreground;
    }
  '';
}
