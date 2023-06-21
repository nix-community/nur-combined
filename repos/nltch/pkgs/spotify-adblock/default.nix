{ stdenv, rustPlatform, fetchFromGitHub, xorg, callPackage }:
rec{
  spotify-adblock = rustPlatform.buildRustPackage {
    pname = "spotify-adblock";
    version = "1.0.2";
    src = fetchFromGitHub {
      owner = "abba23";
      repo = "spotify-adblock";
      rev = "v1.0.2";
      sha256 = "YGD3ymBZ2yT3vrcPRS9YXcljGNczJ1vCvAXz/k16r9Y=";
    };

    cargoSha256 = "bYqkCooBfGeHZHl2/9Om+0qbudyOCzpvwMhy8QCsPRE=";
  };

  

  spotifywm = stdenv.mkDerivation {
    name = "spotifywm";
    src = fetchFromGitHub {
      owner = "dasj";
      repo = "spotifywm";
      rev = "8624f539549973c124ed18753881045968881745";
      sha256 = "sha256-AsXqcoqUXUFxTG+G+31lm45gjP6qGohEnUSUtKypew0=";
    };
    buildInputs = [xorg.libX11];
    installPhase = ''
      mkdir -p $out/lib
      cp spotifywm.so $out/lib/
    '';
  };
  spotify-adblocked = callPackage ./spotify-adblocked.nix {
    inherit spotify-adblock spotifywm;
  };
}