{
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      ipc = false;
      wallpaper = [
        {
          monitor = "";
          path = "${./wallpaper.png}";
        }
      ];
    };
  };
}
