pkgs:

let
  inherit (pkgs) lib;
  nv = import ./_sources/generated.nix { inherit (pkgs) fetchgit fetchurl; };
  optparseApplicativeCompletions = pname: ''
    installShellCompletion --cmd ${pname} \
      --bash <($BIN --bash-completion-script $BIN) \
      --zsh <($BIN --zsh-completion-script $BIN) \
      --fish <($BIN} --fish-completion-script $BIN)
  '';
in
{
  ormolu = pkgs.stdenv.mkDerivation rec {
    inherit (nv.ormolu) pname version src;
    dontUnpack = true;
    nativeBuildInputs = [ pkgs.installShellFiles pkgs.unzip ];
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

  hellsmack = pkgs.stdenv.mkDerivation rec {
    inherit (nv.hellsmack) pname version src;
    dontUnpack = true;
    nativeBuildInputs = [ pkgs.installShellFiles pkgs.unzip ];
    installPhase = ''
      mkdir -p $out/bin
      BIN=$out/bin/${pname}
      unzip ${src}
      install -m755 -D hellsmack $BIN
      ${optparseApplicativeCompletions pname}
    '';

    meta = {
      description = "Minecraft stuff";
      homepage = "https://github.com/amesgen/hellsmack";
      license = lib.licenses.cc0;
      platforms = [ "x86_64-linux" ];
    };
  };

  cabal-docspec = pkgs.stdenv.mkDerivation rec {
    inherit (nv.cabal-docspec) pname version src;
    dontUnpack = true;
    nativeBuildInputs = [ pkgs.installShellFiles ];
    installPhase = ''
      mkdir -p $out/bin
      BIN=$out/bin/${pname}
      unxz -c ${src} > cabal-docspec
      install -m755 -D cabal-docspec $BIN
      ${optparseApplicativeCompletions pname}
    '';

    meta = {
      description = "Another doctest for Haskell";
      homepage = "https://github.com/phadej/cabal-extras/blob/master/cabal-docspec/MANUAL.md";
      license = lib.licenses.gpl2Plus;
      platforms = [ "x86_64-linux" ];
    };
  };

  hlint = pkgs.stdenv.mkDerivation rec {
    inherit (nv.hlint) pname version src;
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.gmp pkgs.ncurses5 ];
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
}
