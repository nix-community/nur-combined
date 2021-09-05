{ automake, autoreconfHook, fetchzip, guile, git, lib, makeWrapper, pkgconfig, sources, stdenv, texinfo }:
let
  mkGuile = { name, src, version, extraInputs ? [], extras ? {}}:
  stdenv.mkDerivation ({
    inherit src version;
    name = "guile-${name}";
    pname = "guile-${name}";
    buildInputs = [ guile git ] ++ extraInputs;
    nativeBuildInputs = [ automake autoreconfHook pkgconfig texinfo ];
    GUILE_AUTO_COMPILE=0;
    # configurePhase = ''
    #    autoreconf -vif && ./configure --prefix=$out
    #   '';
  } // extras);
  guile-config = mkGuile rec {
    name = "config";
    version = "0.5.0";
    src = fetchzip {
      url = "https://gitlab.com/a-sassmannshausen/guile-config/-/archive/${version}/guile-config-${version}.tar.gz";
      sha256 = "1xrl8bdcvvvbsrms0s3pp3d698541fv5b5kyy1z2kwli7akvdiph";
    };
  };
  guile-hall = mkGuile rec {
    name = "hall";
    version = "0.4.0";
    src = fetchzip {
      url = "https://gitlab.com/a-sassmannshausen/guile-hall/-/archive/${version}/guile-hall-${version}.tar.gz";
      sha256 = "0h6a0m8db2a2wmn2i9wia731isl1w97f679i1agskvrjfql4za2b";
    };

    extraInputs = [guile-config makeWrapper];
    extras.postInstall = ''
      cp -r ${guile-config}/lib/ $out
      wrapProgram $out/bin/hall --set GUILE_LOAD_COMPILED_PATH $out/lib/guile/2.2/site-ccache
    '';

  };
in
  guile-hall
