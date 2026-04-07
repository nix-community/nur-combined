# Disclaimer: Some Claude Opus 4.6 was used to write this
{ pkgs }:

let
  # Import nixpkgs with our overlay that adds custom Python packages
  spektrafilm-pkgs = import pkgs.path {
    inherit (pkgs) system;
    config = { allowBroken = true; };
    overlays = [
      (final: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (python-final: python-prev: {
            colour-science = python-final.callPackage ./pkgs/spektrafilm/colour-science.nix { };
            pyfftw = python-final.callPackage ./pkgs/spektrafilm/pyfftw.nix {
              inherit (final) fftw;
            };
            openimageio = python-final.callPackage ./pkgs/spektrafilm/openimageio.nix {
              inherit (final)
                fftw zlib imath openexr libjpeg libtiff libpng
                openimageio freetype opencolorio opencv libraw libheif
                mesa libgbm libglvnd giflib ffmpeg openjph libwebp robin-map
                cmake ninja;
              inherit (final) qt6;
            };
            spektrafilm = python-final.callPackage ./pkgs/spektrafilm/spektrafilm.nix {
              inherit (final) makeWrapper mesa libglvnd;
              qt5 = final.libsForQt5.qt5;
            };
          })
        ];
      })
    ];
  };

  spektrafilm-python = spektrafilm-pkgs.python3.withPackages (ps: with ps; [ numpy scipy spektrafilm ]) ;
  spektrafilm-art = (pkgs.art.overrideAttrs (oldAttrs: {
    version = "1.25.11-unstable-2026-04-01";
    src = pkgs.fetchFromGitHub {
      owner = "artraweditor";
      repo = "ART";
      rev = "27554bbeab0adcd98335b0470b37c7bd3db1ae80";
      hash = "sha256-lCn/qBQ9PEx4pf+0y0fnWHZ2b68Lu6eLKHgcDzNAYio=";
    };
    postInstall = (oldAttrs.postInstall or "") + ''
      mkdir -p $out/share/ART/extlut
      cp -r $src/tools/extlut/* $out/share/ART/extlut/
    '';
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
    postFixup = (oldAttrs.postFixup or "") + ''
      wrapProgram $out/bin/ART \
        --prefix PATH : "${spektrafilm-python}/bin"
      wrapProgram $out/bin/ART-cli \
        --prefix PATH : "${spektrafilm-python}/bin"
    '';
  }));
in
{
  spektrafilm = spektrafilm-pkgs.python3Packages.spektrafilm;
  spektrafilm-art = spektrafilm-art;
}
