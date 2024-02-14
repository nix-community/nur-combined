{ pkgs, ... }: {
  boot.plymouth = {
    enable = true;
    themePackages = with pkgs; [
      (plymouth-themes.override { themes0 = [ "rings_2" ]; })
    ];
    theme = "rings_2";
  };
}
