{ ... }:

{
  programs.git = {
    enable = true;
    extraConfig = {
      init.defaultBranch = "main";
    };
    signing = {
      key = "F90110C7";
      signByDefault = true;
    };
    userName = "P. R. d. O.";
    userEmail = "d.ol.rod@tutanota.com";
  };
}


