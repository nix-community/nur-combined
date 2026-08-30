_: {
  home = {
    username = "ac";
    homeDirectory = "/home/ac";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      user = {
        name = "ahmet-cetinkaya";
        email = "ahmetcetinkaya.me@proton.me";
      };
    };
  };
}
