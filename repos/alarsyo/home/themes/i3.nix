{lib}: let
  inherit
    (lib)
    mkOption
    types
    ;

  mkColorOption = import ./color.nix {inherit lib;};

  barColorSetModule = types.submodule {
    options = {
      border = mkColorOption {};
      background = mkColorOption {};
      text = mkColorOption {};
    };
  };

  colorSetModule = types.submodule {
    options = {
      border = mkColorOption {};
      childBorder = mkColorOption {};
      background = mkColorOption {};
      text = mkColorOption {};
      indicator = mkColorOption {};
    };
  };
in
  types.submodule {
    options = {
      bar = mkOption {
        type = types.submodule {
          options = {
            background = mkColorOption {
              default = "#000000";
              description = "Background color of the bar.";
            };

            statusline = mkColorOption {
              default = "#ffffff";
              description = "Text color to be used for the statusline.";
            };

            separator = mkColorOption {
              default = "#666666";
              description = "Text color to be used for the separator.";
            };

            focusedWorkspace = mkOption {
              type = barColorSetModule;
              default = {
                border = "#4c7899";
                background = "#285577";
                text = "#ffffff";
              };
              description = ''
                Border, background and text color for a workspace button when the workspace has focus.
              '';
            };

            activeWorkspace = mkOption {
              type = barColorSetModule;
              default = {
                border = "#333333";
                background = "#5f676a";
                text = "#ffffff";
              };
              description = ''
                Border, background and text color for a workspace button when the workspace is active.
              '';
            };

            inactiveWorkspace = mkOption {
              type = barColorSetModule;
              default = {
                border = "#333333";
                background = "#222222";
                text = "#888888";
              };
              description = ''
                Border, background and text color for a workspace button when the workspace does not
                have focus and is not active.
              '';
            };

            urgentWorkspace = mkOption {
              type = barColorSetModule;
              default = {
                border = "#2f343a";
                background = "#900000";
                text = "#ffffff";
              };
              description = ''
                Border, background and text color for a workspace button when the workspace contains
                a window with the urgency hint set.
              '';
            };

            bindingMode = mkOption {
              type = barColorSetModule;
              default = {
                border = "#2f343a";
                background = "#900000";
                text = "#ffffff";
              };
              description = "Border, background and text color for the binding mode indicator";
            };
          };
        };

        default = {};
      };

      background = mkOption {
        type = types.str;
        default = "#ffffff";
        description = ''
          Background color of the window. Only applications which do not cover
          the whole area expose the color.
        '';
      };

      focused = mkOption {
        type = colorSetModule;
        default = {
          border = "#4c7899";
          background = "#285577";
          text = "#ffffff";
          indicator = "#2e9ef4";
          childBorder = "#285577";
        };
        description = "A window which currently has the focus.";
      };

      focusedInactive = mkOption {
        type = colorSetModule;
        default = {
          border = "#333333";
          background = "#5f676a";
          text = "#ffffff";
          indicator = "#484e50";
          childBorder = "#5f676a";
        };
        description = ''
          A window which is the focused one of its container,
          but it does not have the focus at the moment.
        '';
      };

      unfocused = mkOption {
        type = colorSetModule;
        default = {
          border = "#333333";
          background = "#222222";
          text = "#888888";
          indicator = "#292d2e";
          childBorder = "#222222";
        };
        description = "A window which is not focused.";
      };

      urgent = mkOption {
        type = colorSetModule;
        default = {
          border = "#2f343a";
          background = "#900000";
          text = "#ffffff";
          indicator = "#900000";
          childBorder = "#900000";
        };
        description = "A window which has its urgency hint activated.";
      };

      placeholder = mkOption {
        type = colorSetModule;
        default = {
          border = "#000000";
          background = "#0c0c0c";
          text = "#ffffff";
          indicator = "#000000";
          childBorder = "#0c0c0c";
        };
        description = ''
          Background and text color are used to draw placeholder window
          contents (when restoring layouts). Border and indicator are ignored.
        '';
      };
    };
  }
