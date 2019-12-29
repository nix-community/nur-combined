{ stdenv, fetchgit, cmake, json_c, ubus, uci, libubox }:

stdenv.mkDerivation rec {
  pname = "ubox";
  version = "2019-12-18";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "b30e0df358bdf8f4f0a5a0858852ca613e3117b8";
    sha256 = "03jw2yim02g3j1p7jz1li3lh0pjwh129vc1dy1nvm3igd50bdylp";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ json_c ubus uci libubox ];
}

