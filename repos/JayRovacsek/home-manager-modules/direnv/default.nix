{ config, pkgs, ... }: {
  programs.direnv = {
    enable = true;
    config = {
      global = { load_dotenv = true; };
      whitelist = {
        prefix =
          [ "/home/jay/dev" "/Users/j.rovacsek/dev" "/Users/jrovacsek/dev" ];
      };
    };
  };
}
