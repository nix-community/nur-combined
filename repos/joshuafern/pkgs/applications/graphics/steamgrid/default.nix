{ stdenv, buildGoPackage, fetchgit }:

buildGoPackage rec {
  name = "steamgrid-unstable-${version}";
  version = "2020-03-22";

  goPackagePath = "github.com/boppreh/steamgrid";

  src = fetchgit {
    rev = "84dcf7a5bad834c0318554117bb1b1e4a5d78ddb";
    url = "https://github.com/boppreh/steamgrid";
    sha256 = "1lcd8c2xiykqi8pp891yp549q0y1kajh5byilwm9imgf2kxzqxb3";
  };

  goDeps = ./deps.nix;

  meta = with stdenv.lib; {
    description = "Downloads images to fill your Steam grid view";
    downloadPage = "https://github.com/boppreh/steamgrid/releases";
    homepage = "https://github.com/boppreh/steamgrid";
    license = licenses.mit;
    longDescription = ''
      SteamGrid is a standalone, fire-and-forget program to enhance Steam's grid view and Big Picture. It preloads the banner images for all your games (even non-Steam ones) and applies overlays depending on your categories.

      You run it once and it'll set up everything above, automatically, keeping your existing custom images. You can run again when you get more games or want to update the category overlays.
    '';
    maintainers = with maintainers; [ joshuafern ];
    platforms = platforms.unix;
  };
}
