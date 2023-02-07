{ config, pkgs, ... }: {
  programs.lsd = {
    enable = true;
    enableAliases = true;
    settings = {
      classic = false;
      blocks = [ "permission" "user" "group" "size" "date" "name" ];
      color.when = "auto";
      date = "date";
      dereference = false;
      indicators = false;
      layout = "grid";
      recursion.enabled = false;
      size = "default";
      no-symlink = false;
      total-size = false;
      symlink-arrow = "⇒";

      icons = {
        when = "auto";
        theme = "fancy";
        seperator = " ";
      };

      sorting = {
        column = "name";
        reverse = false;
        dir-grouping = "none";
      };
    };
  };
}
