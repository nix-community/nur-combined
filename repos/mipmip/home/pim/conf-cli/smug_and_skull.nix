{...}:
let

  projects = {

    nixos = {
      base_dir = "~/nixos";
      repos = [
        { source = "mipmip/nixos";}
      ];

      windows = {
        nixos.commands = [
          ''echo "NIXOS"''
        ];
        switch.commands = [
          ''echo "NIXOS"''
        ];
        secrets = {
          commands = [
            ''echo "NIXOS"''
          ];
          root = "~/nixos/secrets";
        };
      };
    };

    gnome = {
      base_dir = "~/cGnome";
      repos = [
        { source = "mipmip/gnome-hotkeys.cr"; }
        { source = "mipmip/gnome-shell-extensions-highlight-focus";}
        { source = "mipmip/gnome-shell-extensions-hotkeys-popup";}
        { source = "mipmip/gnome-shell-extensions-useless-gaps";}
      ];
    };

  };
in
  {

  programs = {
  smug = {
    enable = true;
    projects = {

      tailscale = {
        root = "~/";
        windows = [
          {
            name = "zsh";
            layout = "main-vertical";
            commands = [
                "tailscale status"
              ];
          }
        ];

      };

        #      blogdemo = {
        #      root = "~/Developer/blog";
        #      before_start = [
        #        "docker-compose -f my-microservices/docker-compose.yml up -d"  # my-microservices/docker-compose.yml is a relative to `root`-al
        #      ];
        #      env = {
        #        FOO = "bar";
        #      };
        #      stop = [
        #        "docker stop $(docker ps -q)"
        #      ];
        #      windows = [
        #        {
        #          name = "code";
        #          root = "blog";
        #          manual = true;
        #          layout = "main-vertical";
        #          commands = [
        #            "docker-compose start"
        #          ];
        #          panes = [
        #            {
        #              type = "horizontal";
        #              root = ".";
        #              commands = [
        #                "docker-compose exec php /bin/sh"
        #                "clear"
        #              ];
        #            }
        #          ];
        #        }
        #
        #        {
        #          name = "infrastructure";
        #          root = "~/Developer/blog/my-microservices";
        #          layout = "tiled";
        #          commands = [
        #            "docker-compose start"
        #          ];
        #          panes = [
        #            {
        #              type = "horizontal";
        #              root = ".";
        #              commands = [
        #                "docker-compose up -d"
        #                "docker-compose exec php /bin/sh"
        #                "clear"
        #              ];
        #            }
        #          ];
        #        }
        #      ];
        #
        #    };

    };
  };
};

}
