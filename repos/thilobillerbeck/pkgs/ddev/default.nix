{ stdenv, buildGoModule, fetchFromGitHub, pkgs }:

buildGoModule rec {
  name = "ddev-${version}";
  version = "v1.12.3";
  src = fetchFromGitHub {
    owner = "drud";
    repo = "ddev";
    rev = version;
    sha256 = "0xm8l4qk8dbywpggafq83imgjmlhamh78jh2qwvqiz89m46w51ih";
  };

  modSha256 = "1bx1nm4qwzmjsch4facvz5pps0ig93ifay8h2vvr9rj9nqby3nwi";

  meta = with stdenv.lib; {
    description = "DDEV";
    homepage = https://github.com/drud/ddev;
    license = with licenses; [ gpl2 ];
    platforms = platforms.linux;
  };
}