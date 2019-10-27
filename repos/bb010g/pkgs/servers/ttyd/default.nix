{ stdenv, fetchFromGitHub, buildPackages
, json_c, libuv, libwebsockets, openssl
}:

stdenv.mkDerivation rec {
  pname = "ttyd";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "tsl0922";
    repo = "ttyd";
    rev = "d8903e1e07322933b4a037ce42f63a9173d347ab";
    sha256 = "16nngc3dqrsgpapzvl34c0msgdd1fyp3k8r1jj1m9bch6z2p50bl";
  };

  nativeBuildInputs = [
    buildPackages.cmake
    buildPackages.pkgconfig
    buildPackages.xxd
  ];
  buildInputs = [
    json_c
    libuv
    libwebsockets
    openssl
  ];

  outputs = [ "out" "man" ];

  meta = let inherit (stdenv) lib; in {
    description = "Share your terminal over the web";
    homepage = https://github.com/tsl0922/ttyd;
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.bb010g ];
    platforms = lib.platforms.linux;
  };
}
