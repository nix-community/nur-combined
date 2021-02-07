rec {
  username = "lucasew";
  email = "lucas59356@gmail.com";
  selectedDesktopEnvironment = "xfce_i3";
  rootPath = "/home/${username}/.dotfiles";
  wallpaper = ./wall.jpg;
  flake = import ./lib/flake {};
}
