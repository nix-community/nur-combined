{ lib
, appimageTools
, fetchurl
}:

appimageTools.wrapType2 rec {
  name = "arctype";
  version = "0.9.64";

  src = fetchurl {
    url = "https://arctype-downloads.s3-us-west-2.amazonaws.com/updates/Arctype-${version}.AppImage";
    sha256 = "sha256-Qm8yp62UMNhGcvm+5l3HXv59qsX6kqFZdKR9bazlK9g=";
  };

  extraPkgs = pkgs: with pkgs; [ libsecret ];

  meta = with lib; {
    description = "The SQL client and database management tool that's fun to use";
    homepage = "https://www.arctype.com";
    license = licenses.unfree;
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.linux;
  };
}
