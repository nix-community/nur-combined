{ lib
, appimageTools
, fetchurl
}:

appimageTools.wrapType2 rec {
  name = "arctype";
  version = "0.9.69";

  src = fetchurl {
    url = "https://arctype-downloads.s3-us-west-2.amazonaws.com/updates/Arctype-${version}.AppImage";
    sha256 = "sha256-df5jgHVZI8ddZGhRwvPaNZWfApWK+jf2l/gkq+JGmu0=";
  };

  extraPkgs = pkgs: with pkgs; [ libsecret ];

  meta = with lib; {
    description = "The SQL client and database management tool that's fun to use";
    homepage = "https://www.arctype.com";
    license = licenses.unfree;
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = [ "x86_64-linux" ];
  };
}
