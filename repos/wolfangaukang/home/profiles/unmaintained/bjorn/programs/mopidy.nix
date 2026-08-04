{ pkgs, ... }:

{
  services.mopidy = {
    enable = true;
    extensionPackages = with pkgs; [
      mopidy-bandcamp
      mopidy-iris
      mopidy-somafm
      mopidy-musicbox-webclient
      #mopidy-podcast
    ];
  };
}
