{ pkgs, ... }: {
  programs.swaylock.settings = {
    show-failed-attempts = true;
    daemonize = true;
    # image =
    #   let
    #     # img = pkgs.fetchurl {
    #     #   url = "https://maxwell.ydns.eu/git/rnhmjoj/nix-slim/raw/branch/master/background.png";
    #     #   name = "img.jpg";
    #     #   hash = "sha256-kqvVGHOaD7shJrvYfhLDvDs62r20wi8Sajth16Spsrk=";
    #     # };
    #     # img-blurred = pkgs.runCommand "img.jpg"
    #     #   {
    #     #     nativeBuildInputs = with pkgs;[ imagemagick ];
    #     #   } "
    #     #    convert -blur 14x5 ${img} $out
    #     #    ";
    #     img-blurred = pkgs.requireFile {
    #       name = "poi.png";
    #       url = "https://placeholder.nyaw.xyz";
    #       sha256 = "6ce4d8445c68e8c6db342a26e9c802bac3753243b1775487e33755d9bf11421f";
    #     };
    #   in
    #   "${img-blurred}";
    scaling = "fill";
    indicator-radius = 100;
    indicator-thickness = 15;
    ring-ver-color = "FEDFE1";
    inside-ver-color = "563F2E00";
    text-ver-color = "FEDFE1";
    font = "Hanken Grotesk";
    ring-clear-color = "86A697";
    inside-clear-color = "563F2E00";
    text-clear-color = "FCFAF2";
    ring-wrong-color = "F17C67";
    inside-wrong-color = "563F2E00";
    text-wrong-color = "F17C67";
    inside-color = "00000000";
    ring-color = "86A697";
    key-hl-color = "FFFFFB";
  };
}
