{ pkgs, ... }: {
  users.users.houbeb = {
    createHome = true;
    description = "Houbeb Ben Othmene";
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "…"
    ];
  };
  home-manager.users.houbeb = {
    home.packages = with pkgs; [ hello ];
  };
}
