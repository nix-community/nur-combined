pkgs:

let
  inherit (pkgs) lib;
  nv = pkgs.callPackage (import ./_sources/generated.nix) { };
  optparseApplicativeCompletions = pname: ''
    installShellCompletion --cmd ${pname} \
      --bash <($BIN --bash-completion-script $BIN) \
      --zsh  <($BIN --zsh-completion-script  $BIN) \
      --fish <($BIN --fish-completion-script $BIN)
  '';
in
lib.mapAttrs (_: pkg: pkgs.callPackage pkg { }) {
  ormolu =
    { lib
    , stdenv
    , installShellFiles
    , unzip
    }:
    stdenv.mkDerivation rec {
      inherit (nv.ormolu) pname version src;
      dontUnpack = true;
      nativeBuildInputs = [ installShellFiles unzip ];
      installPhase = ''
        mkdir -p $out/bin
        BIN=$out/bin/${pname}
        unzip ${src}
        install -m755 -D ormolu $BIN
        ${optparseApplicativeCompletions pname}
      '';

      meta = {
        description = "A formatter for Haskell source code";
        homepage = "https://github.com/tweag/ormolu";
        license = lib.licenses.bsd3;
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        platforms = [ "x86_64-linux" ];
      };
    };

  hellsmack =
    { lib
    , stdenv
    , installShellFiles
    , makeWrapper
    , unzip

    , curl
    , libpulseaudio
    , systemd
    , alsa-lib
    , flite
    , xorg
    }:
    let
      # see https://github.com/NixOS/nixpkgs/blob/f4f5cfb354b63ac74e03694ae88f0e078cbaa29b/pkgs/games/minecraft/default.nix#L44-L51
      libPath = lib.makeLibraryPath [
        curl
        libpulseaudio
        systemd
        alsa-lib # needed for narrator
        flite # needed for narrator
        xorg.libXxf86vm # needed only for versions <1.13
      ];
    in
    stdenv.mkDerivation rec {
      inherit (nv.hellsmack) pname version src;
      dontUnpack = true;
      nativeBuildInputs = [ installShellFiles makeWrapper unzip ];
      installPhase = ''
        mkdir -p $out/bin
        BIN=$out/bin/${pname}
        unzip ${src}
        install -m755 -D hellsmack $BIN
        ${optparseApplicativeCompletions pname}
        wrapProgram $BIN --prefix LD_LIBRARY_PATH : ${libPath}
      '';

      meta = {
        description = "Minecraft stuff";
        homepage = "https://github.com/amesgen/hellsmack";
        license = lib.licenses.cc0;
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        platforms = [ "x86_64-linux" ];
      };
    };

  cabal-docspec =
    { lib
    , stdenv
    , installShellFiles
    }:
    stdenv.mkDerivation rec {
      inherit (nv.cabal-docspec) pname version src;
      dontUnpack = true;
      nativeBuildInputs = [ installShellFiles ];
      installPhase = ''
        mkdir -p $out/bin
        BIN=$out/bin/${pname}
        unxz -c ${src} > cabal-docspec
        install -m755 -D cabal-docspec $BIN
        ${optparseApplicativeCompletions pname}
        installManPage ${nv.cabal-docspec-man.src}
      '';

      meta = {
        description = "Another doctest for Haskell";
        homepage = "https://github.com/phadej/cabal-extras/blob/master/cabal-docspec/MANUAL.md";
        license = lib.licenses.gpl2Plus;
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        platforms = [ "x86_64-linux" ];
      };
    };

  hlint =
    { lib
    , stdenv
    , autoPatchelfHook
    , gmp
    , ncurses5
    }:
    stdenv.mkDerivation rec {
      inherit (nv.hlint) pname version src;
      nativeBuildInputs = [ autoPatchelfHook ];
      buildInputs = [ gmp ncurses5 ];
      installPhase = ''
        mkdir -p $out/bin
        install -m755 -D hlint $out/bin/hlint
      '';

      meta = {
        description = "Source code suggestions";
        homepage = "https://github.com/ndmitchell/hlint";
        license = lib.licenses.bsd3;
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        platforms = [ "x86_64-linux" ];
      };
    };

  cabal-plan =
    { lib
    , stdenv
    , installShellFiles
    }: stdenv.mkDerivation rec {
      inherit (nv.cabal-plan) pname version src;
      dontUnpack = true;
      nativeBuildInputs = [ installShellFiles ];
      installPhase = ''
        mkdir -p $out/bin
        BIN=$out/bin/${pname}
        unxz -c $src > ${pname}
        install -m755 -D ${pname} $BIN
        ${optparseApplicativeCompletions pname}
      '';

      meta = {
        description = "Library and utility for processing cabal's plan.json file";
        homepage = "https://github.com/haskell-hvr/cabal-plan";
        licenses = [ lib.licenses.gpl2Only lib.licenses.gpl3Only ];
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        platforms = [ "x86_64-linux" ];
      };
    };

  fourmolu =
    { lib
    , stdenv
    , autoPatchelfHook
    , installShellFiles
    , gmp
    }:
    stdenv.mkDerivation rec {
      inherit (nv.fourmolu) pname version src;
      dontUnpack = true;
      nativeBuildInputs = [ autoPatchelfHook installShellFiles ];
      buildInputs = [ gmp ];
      installPhase = ''
        mkdir -p $out/bin
        BIN=$out/bin/${pname}
        install -m755 -D $src $BIN
        ${optparseApplicativeCompletions pname}
      '';

      meta = {
        description = "A configurable formatter for Haskell source code";
        homepage = "https://github.com/fourmolu/fourmolu";
        license = lib.licenses.bsd3;
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        platforms = [ "x86_64-linux" ];
      };
    };

  cabal-gild =
    { lib
    , stdenv
    , autoPatchelfHook
    , gmp
    }:
    stdenv.mkDerivation rec {
      inherit (nv.cabal-gild) pname version src;
      unpackPhase = ''
        tar xf $src
      '';
      nativeBuildInputs = [ autoPatchelfHook ];
      buildInputs = [ gmp ];
      installPhase = ''
        mkdir -p $out/bin
        install -m755 -D cabal-gild $out/bin/cabal-gild
      '';

      meta = {
        description = "Format Haskell package descriptions";
        homepage = "https://github.com/tfausak/cabal-gild";
        license = lib.licenses.mit;
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        platforms = [ "x86_64-linux" ];
      };
    };
}
