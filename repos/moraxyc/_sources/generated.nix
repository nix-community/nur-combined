# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  exloli-next = {
    pname = "exloli-next";
    version = "41d7a6e52a1625d6febb47160a4b143ca47c16d5";
    src = fetchFromGitHub {
      owner = "lolishinshi";
      repo = "exloli-next";
      rev = "41d7a6e52a1625d6febb47160a4b143ca47c16d5";
      fetchSubmodules = false;
      sha256 = "sha256-S3hjuRSDtPkK9XF2USXfyOawWoD/fu9qYDJbUPI3Op0=";
    };
    date = "2024-11-23";
  };
  libinput-three-finger-drag = {
    pname = "libinput-three-finger-drag";
    version = "6acd3f84b551b855b5f21b08db55e95dae3305c5";
    src = fetchFromGitHub {
      owner = "marsqing";
      repo = "libinput-three-finger-drag";
      rev = "6acd3f84b551b855b5f21b08db55e95dae3305c5";
      fetchSubmodules = false;
      sha256 = "sha256-xmcTb+23d6mMzIfMVjzN6bwV0fWH4p6YhXXqrFmt4TM=";
    };
    date = "2024-06-17";
  };
  v2ray-rules-dat-geoip = {
    pname = "v2ray-rules-dat-geoip";
    version = "202503152212";
    src = fetchurl {
      url = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/202503152212/geoip.dat";
      sha256 = "sha256-4yuAAX0d6pG8NsTn7Qel5/IANWQV5niopvgl+1Ife2g=";
    };
  };
  v2ray-rules-dat-geosite = {
    pname = "v2ray-rules-dat-geosite";
    version = "202503152212";
    src = fetchurl {
      url = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/202503152212/geosite.dat";
      sha256 = "sha256-mZD37n6WNXdqF87VPp1U4lLcy46cTuyxnu/yycOWKak=";
    };
  };
}
