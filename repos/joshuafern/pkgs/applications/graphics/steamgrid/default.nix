{ stdenv, buildGoPackage, fetchgit }:

buildGoPackage rec {
  name = "steamgrid-unstable-${version}";
  version = "2020-01-28";
  rev = "0318b952ba65f392d2b80407998e563f848504d9";

  goPackagePath = "github.com/boppreh/steamgrid";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/boppreh/steamgrid";
    sha256 = "0nnnwwqg440gdswgak99yqr9ndp82cqh2dgpw14hmxnwi6pi62m1";
  };

  goDeps = ./deps.nix;

  meta = with stdenv.lib; {
    description = "Downloads images to fill your Steam grid view";
    downloadPage = https://github.com/boppreh/steamgrid/releases;
    homepage = https://github.com/boppreh/steamgrid;
    license = licenses.mit;
    longDescription = ''
    SteamGrid is a standalone, fire-and-forget program to enhance Steam's grid view and Big Picture. It preloads the banner images for all your games (even non-Steam ones) and applies overlays depending on your categories.

    You run it once and it'll set up everything above, automatically, keeping your existing custom images. You can run again when you get more games or want to update the category overlays.
    '';
    maintainers = with maintainers; [ joshuafern ];
    platforms = platforms.unix;
  };
}
