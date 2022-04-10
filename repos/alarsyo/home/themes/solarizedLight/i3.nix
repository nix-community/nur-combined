let
  inherit
    (import ./colors.nix)
    base00
    base2
    base3
    blue
    magenta
    orange
    red
    yellow
    ;
in {
  bar = {
    background = base3;
    statusline = yellow;
    separator = red;

    focusedWorkspace = {
      border = blue;
      background = blue;
      text = base3; # base2 ?
    };
    inactiveWorkspace = {
      border = base2;
      background = base2;
      text = base00;
    };
    activeWorkspace = {
      border = blue;
      background = base2;
      text = yellow;
    };
    urgentWorkspace = {
      border = red;
      background = red;
      text = base3;
    };
  };

  focused = {
    border = blue;
    background = blue;
    text = base3;
    indicator = magenta;
    childBorder = blue;
  };

  focusedInactive = {
    border = base2;
    background = base2;
    text = base00;
    indicator = magenta;
    childBorder = base2;
  };

  unfocused = {
    border = base2;
    background = base2;
    text = base00;
    indicator = magenta;
    childBorder = base2;
  };

  urgent = {
    border = orange;
    background = orange;
    text = base3;
    indicator = magenta;
    childBorder = orange;
  };
}
