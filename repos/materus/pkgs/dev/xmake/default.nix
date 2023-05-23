{ pkgs, lib, stdenv, fetchFromGitHub }:


stdenv.mkDerivation rec {
  pname = "xmake";
  version = "v2.7.9";
  src =  fetchFromGitHub {
    owner = "xmake-io";
    repo = "xmake";
    rev = version;
    sha256 = "sha256-Op13Rx+meY6ZN2xvyj/9rNUPmXsHMQoVJSpxZCiRc6A=";
    fetchSubmodules = true;
  };

  meta = with lib; {
    description = "A cross-platform build utility based on Lua";
    homepage = "https://xmake.io";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
