pkgs:

let
  inherit (pkgs) lib;
  nv = pkgs.callPackage (import ./_sources/generated.nix) { };
  optparseApplicativeCompletions = pname: ''
    installShellCompletion --cmd ${pname} \
      --bash <($BIN --bash-completion-script $BIN) \
      --zsh <($BIN --zsh-completion-script $BIN) \
      --fish <($BIN} --fish-completion-script $BIN)
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
        platforms = [ "x86_64-linux" ];
      };
    };

  nix-index-database =
    { lib
    , stdenv
    }:
    stdenv.mkDerivation {
      inherit (nv.nix-index-database) pname version src;
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out
        cp $src $out/files
      '';

      meta = {
        description = "Weekly updated nix-index database";
        homepage = "https://github.com/Mic92/nix-index-database";
        license = lib.licenses.mit;
        platforms = lib.platforms.all;
      };
    };
}
