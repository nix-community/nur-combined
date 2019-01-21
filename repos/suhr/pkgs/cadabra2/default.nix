{ stdenv, fetchFromGitHub
, pkgconfig, cmake, wrapGAppsHook
, python3, pcre-cpp, gmp, gnome3, boost, sqlite, libuuid, texlive
}:

let
  pythonEnv = python3.withPackages(ps: with ps; [ matplotlib mpmath sympy ]);
in
  stdenv.mkDerivation rec {
    name = "cadabra2-${version}";
    version = "2.2.4";

    src = fetchFromGitHub {
      owner = "kpeeters";
      repo = "cadabra2";
      rev = "d11e42b67ee59fd5e6688ce18d5516e08cfc08f0";
      sha256 = "0q4bwwrd1ndq7m4a7jja4x5fjyvijf9vnbpx9h8js1jq75p2wp9g";
    };

    buildInputs = [
      pythonEnv pcre-cpp gmp gnome3.gtkmm boost sqlite libuuid texlive.combined.scheme-basic
    ];

    nativeBuildInputs = [
      pkgconfig cmake wrapGAppsHook
    ];

    meta = with stdenv.lib; {
      description = "Advanced IRC Client";
      homepage = http://www.kvirc.net/;
      license = licenses.gpl2;
      maintainers = [ ];
      platforms = platforms.linux;
    };
  }
