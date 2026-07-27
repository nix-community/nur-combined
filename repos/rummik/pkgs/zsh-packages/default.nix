{ mkPackage }:

rec {
  revolver = mkPackage {} (
    { stdenv, fetchFromGitHub, writeScript, zsh }:

    stdenv.mkDerivation rec {
      name = "revolver";
      version = "0.2.3";

      src = fetchFromGitHub {
        owner = "molovo";
        repo = "revolver";
        rev = "v${version}";
        sha256 = "122zb5vpsaqc2s8dm4i79y7vdayn8prpv9jfyypzp7v38hq2h9h0";
      };

      dontStrip = true;
      dontPatchELF = true;
      dontBuild = true;

      buildInputs = [ zsh ];

      installPhase = /* sh */ ''
        mkdir -p $out/{bin,share/zsh/site-functions}
        chmod a+x revolver
        cp revolver $out/bin
        cp revolver.zsh-completion $out/share/zsh/site-functions/_revolver
      '';
    }
  );

  zunit = mkPackage { inherit revolver; } (
    { stdenv, fetchFromGitHub, writeScript, zsh, revolver }:

    stdenv.mkDerivation rec {
      name = "zunit";
      version = "0.8.2";

      src = fetchFromGitHub {
        owner = "zunit-zsh";
        repo = "zunit";
        rev = "v${version}";
        sha256 = "0dxa0fmjgqrf5awx7mh9s09pqdmw0nzfpnhbhs0apjx1i7k1nm96";
      };

      dontStrip = true;
      dontPatchELF = true;

      buildInputs = [ zsh revolver ];

      buildPhase = /* sh */ ''
        [[ -f build.zsh ]] && zsh build.zsh
      '';

      installPhase = /* sh */ ''
        mkdir -p $out/{bin,share/zsh/site-functions}
        chmod a+x zunit
        cp zunit $out/bin
        cp zunit.zsh-completion $out/share/zsh/site-functions/_zunit
      '';
    }
  );
}
