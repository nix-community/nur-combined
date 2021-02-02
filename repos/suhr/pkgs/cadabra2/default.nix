{ stdenv, lib, fetchFromGitHub, makeWrapper
, pkgconfig, cmake, gsettings-desktop-schemas
, python3, pcre-cpp, gmp, gnome3, boost, sqlite, libuuid, texlive
}:

let
  pythonEnv = python3.withPackages(ps: with ps; [ matplotlib mpmath sympy ]);
in
  stdenv.mkDerivation rec {
    name = "cadabra2-${version}";
    version = "2.2.5";

    src = fetchFromGitHub {
      owner = "kpeeters";
      repo = "cadabra2";
      rev = "${version}";
      sha256 = "16q1n16c7zsy94m2mgaz4j4dxsi3lgrqhg3jkmzggfj7nq7f6yn1";
    };

    buildInputs = [
      pythonEnv pcre-cpp gmp gnome3.gtkmm boost sqlite libuuid texlive.combined.scheme-basic
      gsettings-desktop-schemas
    ];

    nativeBuildInputs = [
      pkgconfig cmake makeWrapper
    ];

    preFixup = ''
      sed -i -e "s:share/cadabra2:$out/share/cadabra2:g" $out/bin/cadabra2
      wrapProgram $out/bin/cadabra2-gtk \
        --prefix GIO_EXTRA_MODULES : "${lib.getLib gnome3.dconf}/lib/gio/modules" \
        --prefix XDG_DATA_DIRS : "$out/share" \
        --prefix XDG_DATA_DIRS : "$out/share/gsettings-schemas/${name}" \
        --prefix XDG_DATA_DIRS : "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}"
    '';

    meta = with lib; {
      description = "A field-theory motivated approach to computer algebra";
      homepage = https://cadabra.science/;
      license = licenses.gpl3;
      maintainers = [ ];
      platforms = platforms.linux;
    };
  }
