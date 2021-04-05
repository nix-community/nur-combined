{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  version = "unstable-2021-05-03";
  pname = "hdl_dump";

  src = fetchFromGitHub {
    owner = "ps2homebrew";
    repo = "hdl-dump";
    rev = "58b6f6ce9c2c142ded18da99b219fa75e85c06ac";
    sha256 = "sha256-zzHpHBG9HEMyiztGfJ7gcRf4VKm2fsvdUDkr7lY9ixA=";
  };

  makeFlags = [ "RELEASE=yes" ];

  installPhase = ''
    install -Dm755 hdl_dump -t $out/bin
  '';

  meta = with lib; {
    inherit (src.meta) homepage;
    description = "PlayStation 2 HDLoader image dump/install utility";
    platforms = platforms.linux;
    license = licenses.gpl2;
    maintainers = with maintainers; [ genesis ];
  };
}
