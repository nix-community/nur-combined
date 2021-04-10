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
      url = "https://gitlab.com/a-sassmannshausen/guile-config/-/archive/0.5.0/guile-config-0.5.0.tar.gz";
      sha256 = "1xrl8bdcvvvbsrms0s3pp3d698541fv5b5kyy1z2kwli7akvdiph";
    };
  };
  guile-hall = mkGuile rec {
    name = "hall";
    version = "0.3.1";
    src = fetchzip {
      url = "https://gitlab.com/a-sassmannshausen/guile-hall/-/archive/0.3.1/guile-hall-0.3.1.tar.gz";
      sha256 = "1s24nigdra6rvclvy15l2aw00c3aq9vv8qwxylzs60darbl36206";
    };
    
    extraInputs = [guile-config makeWrapper];
    extras.postInstall = ''
      cp -r ${guile-config}/lib/ $out
      wrapProgram $out/bin/hall --set GUILE_LOAD_COMPILED_PATH $out/lib/guile/2.2/site-ccache
    '';

  };
in
  guile-hall

