{pkgs, ...}:
{
  home.packages = with pkgs; [
    gimp
    kdeApplications.kdenlive
    vlc
    youtube-dl
  ];
}
