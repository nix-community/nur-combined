{
  user,
  lib,
  pkgs,
  inputs',
  ...
}:
{
  programs.niri = {
    # aligh waybar rpc etc
    package = pkgs.niri;
    enable = true;
  };
  services.greetd = {
    enable = true;
    vt = 2;
    settings = rec {
      initial_session = {
        command = "${lib.getExe pkgs.greetd.tuigreet} --remember --time --cmd ${lib.getExe' pkgs.niri "niri-session"}";
        inherit user;
      };
      default_session = initial_session;
    };
  };

  # services.lemurs = {
  #   enable = true;
  #   package = pkgs.lemurs;
  #   settings = {
  #     background = {
  #       show_background = false;
  #       style = {
  #         border_color = "white";
  #         color = "black";
  #         show_border = true;
  #       };
  #     };
  #     cache_path = "/var/cache/lemurs";
  #     client_log_path = "/var/log/lemurs.client.log";
  #     do_log = true;
  #     environment_switcher = {
  #       include_tty_shell = false;
  #       left_mover = "<";
  #       max_display_length = 8;
  #       mover_color = "dark gray";
  #       mover_color_focused = "orange";
  #       mover_margin = 1;
  #       mover_modifiers = "";
  #       mover_modifiers_focused = "bold";
  #       neighbour_color = "dark gray";
  #       neighbour_color_focused = "gray";
  #       neighbour_margin = 1;
  #       neighbour_modifiers = "";
  #       neighbour_modifiers_focused = "";
  #       no_envs_color = "white";
  #       no_envs_color_focused = "red";
  #       no_envs_modifiers = "";
  #       no_envs_modifiers_focused = "";
  #       no_envs_text = "No environments...";
  #       remember = true;
  #       right_mover = ">";
  #       selected_color = "gray";
  #       selected_color_focused = "white";
  #       selected_modifiers = "underlined";
  #       selected_modifiers_focused = "bold";
  #       show_movers = true;
  #       show_neighbours = true;
  #       switcher_visibility = "visible";
  #       toggle_hint = "Switcher %key%";
  #       toggle_hint_color = "dark gray";
  #       toggle_hint_modifiers = "";
  #     };
  #     focus_behaviour = "password";
  #     main_log_path = "/var/log/lemurs.log";
  #     pam_service = "lemurs";
  #     password_field = {
  #       content_replacement_character = "*";
  #       style = {
  #         border_color = "white";
  #         border_color_focused = "orange";
  #         content_color = "white";
  #         content_color_focused = "orange";
  #         max_width = 48;
  #         show_border = true;
  #         show_title = true;
  #         title = "Password";
  #         title_color = "white";
  #         title_color_focused = "orange";
  #         use_max_width = true;
  #       };
  #     };
  #     power_controls = {
  #       base_entries = [
  #         {
  #           cmd = "systemctl poweroff -l";
  #           hint = "Shutdown";
  #           hint_color = "dark gray";
  #           hint_modifiers = "";
  #           key = "F1";
  #         }
  #         {
  #           cmd = "systemctl reboot -l";
  #           hint = "Reboot";
  #           hint_color = "dark gray";
  #           hint_modifiers = "";
  #           key = "F2";
  #         }
  #       ];
  #       entries = [ ];
  #       hint_margin = 2;
  #     };
  #     shell_login_flag = "short";
  #     system_shell = lib.getExe pkgs.bash;
  #     tty = 2;
  #     username_field = {
  #       remember = true;
  #       style = {
  #         border_color = "white";
  #         border_color_focused = "orange";
  #         content_color = "white";
  #         content_color_focused = "orange";
  #         max_width = 48;
  #         show_border = true;
  #         show_title = true;
  #         title = "Login";
  #         title_color = "white";
  #         title_color_focused = "orange";
  #         use_max_width = true;
  #       };
  #     };
  #   };
  # };
  systemd.user = {
    services = {
      swaybg = {
        wantedBy = [ "niri.service" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart =
            let
              img = pkgs.fetchurl {
                url = "https://s3.nyaw.xyz/misskey//92772482-aef9-44e8-b1e2-1d49753a72fc.jpg";
                hash = "sha256-Y9TJ/xQQhqWq3t2wn1gS4NPGpuz1m7nu1ATcWWPKPW8=";
              };
            in
            "${lib.getExe pkgs.swaybg} -i ${img} -m fill";
          Restart = "on-failure";
        };
      };
      waybar = {
        wantedBy = [ "niri.service" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        # path = [ (lib.makeBinPath [ pkgs.niri ]) ];
        serviceConfig = {
          ExecStart = lib.getExe pkgs.waybar;
          Restart = "on-failure";
        };
      };
      # xwayland-satellite = {
      #   wantedBy = [ "niri.service" ];
      #   after = [ "graphical-session.target" ];
      #   wants = [ "graphical-session.target" ];
      #   serviceConfig = {
      #     ExecStart = lib.getExe pkgs.xwayland-satellite;
      #     Restart = "on-failure";
      #   };
      # };
    };
  };
}
