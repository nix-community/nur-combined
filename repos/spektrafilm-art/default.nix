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
            lensfunpy = python-final.callPackage ./pkgs/spektrafilm/lensfunpy.nix {
              inherit (final) lensfun pkg-config;
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
    version = "1.26.6";
    src = pkgs.fetchFromGitHub {
      owner = "artraweditor";
      repo = "ART";
      rev = "9fee76b983b7727b9371b630f2fa61cf0ba94562";
      hash = "sha256-m5KQUY7loLKH7X2cDw5n7biH1GJTVONTbguILdjNWrI=";
    };
    meta = (oldAttrs.meta or {}) // {
      mainProgram = "ART";
    };
    patches = (oldAttrs.patches or []) ++ [
      ./pkgs/spektrafilm/art-spektrafilm-luts-dir.patch
    ];
    postInstall = (oldAttrs.postInstall or "") + ''
      mkdir -p $out/share/ART/extlut
      cp -r $src/tools/extlut/* $out/share/ART/extlut/

      mkdir -p $out/share/ART/spektrafilm-luts
      cp $out/share/ART/extlut/ART_spektrafilm.json $out/share/ART/spektrafilm-luts/
      cp $out/share/ART/extlut/spektrafilm_mklut.py $out/share/ART/spektrafilm-luts/
      substituteInPlace $out/share/ART/extlut/ART_spektrafilm.json \
        --replace-fail '"command" : "python3 spektrafilm_mklut.py --server",' \
                       '"command" : "${spektrafilm-python}/bin/python spektrafilm_mklut.py --server",'
      substituteInPlace $out/share/ART/spektrafilm-luts/ART_spektrafilm.json \
        --replace-fail '"command" : "python3 spektrafilm_mklut.py --server",' \
                       '"command" : "${spektrafilm-python}/bin/python spektrafilm_mklut.py --server",'
    '';
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
    postFixup = (oldAttrs.postFixup or "") + ''
      wrapProgram $out/bin/ART \
        --run 'spektrafilm_luts_data_home="''${XDG_DATA_HOME:-''${HOME:+$HOME/.local/share}}"; spektrafilm_luts_dir="$spektrafilm_luts_data_home/ART/spektrafilm-luts"; if [ -n "$spektrafilm_luts_data_home" ]; then mkdir -p "$spektrafilm_luts_data_home/ART"; if [ -L "$spektrafilm_luts_dir" ] || [ ! -e "$spektrafilm_luts_dir" ]; then ln -sfn '"$out"'/share/ART/spektrafilm-luts "$spektrafilm_luts_dir"; fi; fi' \
        --prefix PATH : "${spektrafilm-python}/bin"
      wrapProgram $out/bin/ART-cli \
        --run 'spektrafilm_luts_data_home="''${XDG_DATA_HOME:-''${HOME:+$HOME/.local/share}}"; spektrafilm_luts_dir="$spektrafilm_luts_data_home/ART/spektrafilm-luts"; if [ -n "$spektrafilm_luts_data_home" ]; then mkdir -p "$spektrafilm_luts_data_home/ART"; if [ -L "$spektrafilm_luts_dir" ] || [ ! -e "$spektrafilm_luts_dir" ]; then ln -sfn '"$out"'/share/ART/spektrafilm-luts "$spektrafilm_luts_dir"; fi; fi' \
        --prefix PATH : "${spektrafilm-python}/bin"
    '';
  }));
in
{
  spektrafilm = spektrafilm-pkgs.python3Packages.spektrafilm;
  spektrafilm-art = spektrafilm-art;
}
