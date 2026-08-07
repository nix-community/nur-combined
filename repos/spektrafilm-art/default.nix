# Disclaimer: Some Claude Opus 4.6 was used to write this
#
# `pkgsDarktable` is an optional second nixpkgs used only as the base for the
# darktable-spektrafilm build (see pkgs/darktable-spektrafilm/). It defaults to
# `pkgs` so this file still works when imported standalone or via overlay.nix.
{ pkgs, pkgsDarktable ? pkgs }:

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
            pyconify = python-final.callPackage ./pkgs/spektrafilm/pyconify.nix { };
            spektrafilm = python-final.callPackage ./pkgs/spektrafilm/spektrafilm.nix {
              inherit (final) makeWrapper mesa libglvnd;
              inherit (final) qt6;
            };
          })
        ];
      })
    ];
  };

  spektrafilm-python = spektrafilm-pkgs.python3.withPackages (ps: with ps; [ numpy scipy spektrafilm ]) ;
  # Mirrors the canonical published pack repo (pinned), byte-identical to what
  # darktable's in-UI downloader installs. No longer generated from the Python
  # spektrafilm package. Exposes `.lutHash` for placement under packs/<hash>/.
  spektrafilmDataPack =
    pkgs.callPackage ./pkgs/darktable-spektrafilm/data-pack.nix { };
  darktableAiModels =
    pkgs.callPackage ./pkgs/darktable-spektrafilm/ai-models.nix { };
  spektrafilmArtBase = (pkgs.art.overrideAttrs (oldAttrs: {
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
      ./pkgs/spektrafilm/art-film-simulation-empty-lut-noop.patch
    ];
    postInstall = (oldAttrs.postInstall or "") + ''
      mkdir -p $out/share/ART/extlut
      cp -r $src/tools/extlut/* $out/share/ART/extlut/

      mkdir -p $out/share/ART/spektrafilm-luts
      cp $out/share/ART/extlut/ART_spektrafilm.json $out/share/ART/spektrafilm-luts/
      cp $out/share/ART/extlut/spektrafilm_mklut.py $out/share/ART/spektrafilm-luts/
    '';
  }));
  spektrafilm-art = pkgs.symlinkJoin {
    name = "spektrafilm-art-${spektrafilmArtBase.version}";
    paths = [ spektrafilmArtBase ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/share/ART/spektrafilm-luts/ART_spektrafilm.json
      rm $out/share/ART/spektrafilm-luts/spektrafilm_mklut.py
      cp ${spektrafilmArtBase}/share/ART/spektrafilm-luts/ART_spektrafilm.json $out/share/ART/spektrafilm-luts/
      cp ${spektrafilmArtBase}/share/ART/spektrafilm-luts/spektrafilm_mklut.py $out/share/ART/spektrafilm-luts/
      chmod +w $out/share/ART/spektrafilm-luts/ART_spektrafilm.json
      chmod +w $out/share/ART/spektrafilm-luts/spektrafilm_mklut.py

      substituteInPlace $out/share/ART/spektrafilm-luts/ART_spektrafilm.json \
        --replace-fail '"command" : "python3 spektrafilm_mklut.py --server",' \
                       '"command" : "${spektrafilm-python}/bin/python spektrafilm_mklut.py --server",'
      substituteInPlace $out/share/ART/spektrafilm-luts/spektrafilm_mklut.py \
        --replace-fail '    from spektrafilm.model.stocks import FilmStocks, PrintPapers' \
                       '    from spektrafilm_gui.options import FilmStocks, PrintStocks as PrintPapers'

      wrapProgram $out/bin/ART \
        --run 'spektrafilm_luts_data_home="''${XDG_DATA_HOME:-''${HOME:+$HOME/.local/share}}"; spektrafilm_luts_dir="$spektrafilm_luts_data_home/ART/spektrafilm-luts"; if [ -n "$spektrafilm_luts_data_home" ]; then mkdir -p "$spektrafilm_luts_data_home/ART"; if [ -L "$spektrafilm_luts_dir" ] || [ ! -e "$spektrafilm_luts_dir" ]; then ln -sfn '"$out"'/share/ART/spektrafilm-luts "$spektrafilm_luts_dir"; fi; fi' \
        --prefix PATH : "${spektrafilm-python}/bin"
      wrapProgram $out/bin/ART-cli \
        --run 'spektrafilm_luts_data_home="''${XDG_DATA_HOME:-''${HOME:+$HOME/.local/share}}"; spektrafilm_luts_dir="$spektrafilm_luts_data_home/ART/spektrafilm-luts"; if [ -n "$spektrafilm_luts_data_home" ]; then mkdir -p "$spektrafilm_luts_data_home/ART"; if [ -L "$spektrafilm_luts_dir" ] || [ ! -e "$spektrafilm_luts_dir" ]; then ln -sfn '"$out"'/share/ART/spektrafilm-luts "$spektrafilm_luts_dir"; fi; fi' \
        --prefix PATH : "${spektrafilm-python}/bin"
    '';
    passthru = (spektrafilmArtBase.passthru or { }) // {
      basePackage = spektrafilmArtBase;
    };
    meta = (spektrafilmArtBase.meta or { }) // {
      mainProgram = "ART";
    };
  };
  darktableSpektrafilm =
    pkgsDarktable.callPackage ./pkgs/darktable-spektrafilm/darktable-spektrafilm.nix {
      inherit spektrafilmDataPack darktableAiModels;
    };
in
{
  spektrafilm = spektrafilm-pkgs.python3Packages.spektrafilm;
  spektrafilm-art = spektrafilm-art;

  # darktable built from the spektrafilm PR branch (native C module,
  # independent of the spektrafilm Python package above). Based on pkgsDarktable
  # (nixpkgs-unstable) for a dependency set close to the 5.8.0 source.
  darktable-spektrafilm = darktableSpektrafilm;
  darktable-spektrafilm-ai = darktableSpektrafilm.override { withAi = true; };

  # Runtime film/print data pack for the module above.
  spektrafilm-data-pack = spektrafilmDataPack;

  # darktable AI models (denoise/upscale/object-masking), bundled for offline
  # use since the fork's 5.8.0 version has no auto-download match. Link into
  # ~/.local/share/darktable/models. Override `models` to pick a different set.
  darktable-ai-models = darktableAiModels;
}
