rec {
  username = "lucasew";
  email = "lucas59356@gmail.com";
  selectedDesktopEnvironment = "xfce_i3";
  rootPath = "/home/${username}/.dotfiles";
  # rootPathNix = "${rootPath}";
  wallpaper = rootPath + "/wall.jpg";
  # flake = builtins.getFlake (builtins.toString ./.);
}
