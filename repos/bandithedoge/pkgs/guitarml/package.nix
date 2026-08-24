{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  juceCmakeHook,
}:
let
  mkGuitarMl =
    {
      pname,
      version,
      src,
      meta,
      branch ? false,
    }:
    stdenv.mkDerivation {
      inherit pname version src;

      nativeBuildInputs = [ juceCmakeHook ];

      passthru.updateScript = nix-update-script {
        extraArgs = lib.optionals branch [
          "--version"
          "branch"
        ];
      };

      meta = {
        license = lib.licenses.gpl3Plus;
        platforms = lib.platforms.linux;
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    };
in
{
  proteus = mkGuitarMl rec {
    pname = "proteus";
    version = "1.2";
    src = fetchFromGitHub {
      owner = "GuitarML";
      repo = "Proteus";
      rev = "v${version}";
      hash = "sha256-WhJh+Sx64JYxQQ1LXpDUwXeodFU1EZ0TmMhn+6w0hQg=";
      fetchSubmodules = true;
    };

    meta = {
      homepage = "https://github.com/GuitarML/Proteus";
      description = "Guitar amp and pedal capture plugin using neural networks";
      mainProgram = "Proteus";
    };
  };

  prince = mkGuitarMl rec {
    pname = "prince";
    version = "1.0";
    src = fetchFromGitHub {
      owner = "GuitarML";
      repo = "PrincePedal";
      rev = "v${version}";
      hash = "sha256-mCDbfzSC8MnL1Lkeft5UznMo69Sty9VcJvn/yR76d3s=";
      fetchSubmodules = true;
    };

    meta = {
      homepage = "https://github.com/GuitarML/PrincePedal";
      description = "Prince of Tone style guitar plugin made with neural networks";
      mainProgram = "Prince";
    };
  };

  ts-m1n3 = mkGuitarMl {
    pname = "ts-m1n3";
    version = "1.2.0-unstable-2023-01-05";
    src = fetchFromGitHub {
      owner = "GuitarML";
      repo = "TS-M1N3";
      rev = "f1cf48c3188c76d7ebf0ead1d7979f7e72f12661";
      hash = "sha256-ItxkbMtF2xOUb/mYL/K5s9S9GTrHlsCsAl/P0EDM3xs=";
      fetchSubmodules = true;
    };
    branch = true;

    meta = {
      homepage = "https://github.com/GuitarML/TS-M1N3";
      description = "TS-9 guitar pedal clone using neural networks";
    };
  };

  chameleon = mkGuitarMl {
    pname = "chameleon";
    version = "1.2.0-unstable-2023-01-05";
    src = fetchFromGitHub {
      owner = "GuitarML";
      repo = "Chameleon";
      rev = "bf0b03b4ebead33c84432e3beabe199ff0fa847e";
      hash = "sha256-Y8oQ3ONHeQn0v7CXR6Jln5yb+CvVR4lXQlJeOm5jsuY=";
      fetchSubmodules = true;
    };
    branch = true;

    meta = {
      homepage = "https://github.com/GuitarML/Chameleon";
      description = "Vintage guitar amp using neural networks";
    };
  };

  smartamp = mkGuitarMl {
    pname = "smartamp";
    version = "1.3-unstable-2023-04-11";
    src = fetchFromGitHub {
      owner = "GuitarML";
      repo = "SmartGuitarAmp";
      rev = "883944d1b46d03e6e906602db2f15cf24ecb743b";
      hash = "sha256-1pS3gSpvncEJqvB96PKbxlfV/Besdvd5pKs7VVfG1pE=";
      fetchSubmodules = true;
    };
    branch = true;

    meta = {
      homepage = "https://github.com/GuitarML/SmartGuitarAmp";
      description = "Guitar plugin made with JUCE that uses neural networks to emulate a tube amplifier";
    };
  };

  smartpedal = mkGuitarMl {
    pname = "smartpedal";
    version = "1.5-unstable-2022-10-12";
    src = fetchFromGitHub {
      owner = "GuitarML";
      repo = "SmartGuitarPedal";
      rev = "fede0242a4d77fff609a49b9277151bfb63cd3cf";
      hash = "sha256-ZqkHF07FHlTvViJCdd/t2ge9JwpTiG/PYt2gMFJzKD8=";
      fetchSubmodules = true;
    };
    branch = true;

    meta = {
      homepage = "https://github.com/GuitarML/SmartGuitarPedal";
      description = "Guitar plugin made with JUCE that uses neural network models to emulate real world hardware";
    };
  };
}
