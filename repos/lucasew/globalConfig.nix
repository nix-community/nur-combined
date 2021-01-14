rec {
    username = "lucasew";
    email = "lucas59356@gmail.com";
    selectedDesktopEnvironment = "xfce_i3";
    rootPath = "/home/${username}/.dotfiles";
    wallpaper = builtins.fetchurl {
      url = "http://wallpaperswide.com/download/aurora_sky-wallpaper-1366x768.jpg";
      sha256 = "1gk4bw5mj6qgk054w4g0g1zjcnss843afq5h5k0qpsq9sh28g41a";
  };
  flake = import ./lib/flake {};
}
