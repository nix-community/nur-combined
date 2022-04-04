{ pkgs ? import <nixpkgs> {} }:
with pkgs;

((rustPlatform.buildRustPackage.override {
    stdenv = clangStdenv; # disable clang and see what happens.. seem to work for now.
  }) rec {
  name = "grin-${version}";
  version = "0.5.2";
  buildInputs = [ ncurses zeromq pkgconfig openssl cmake clang zlib czmq ];

  src = fetchFromGitHub {
    owner = "mimblewimble";
    repo = "grin";
    rev = "ba994248ac7f4e4e9e24abb5c654051f81862779";
    sha256 = "00lmvhx5mmsna87vrdhaff8v8hqdhakr77ax1rarrqzjggpnm4gb";
  };

  cargoSha256 = "19snmmrqb8ar5072jpq905asazanpm7fbpn8p9x023cfnlc2g1c4";

  # tests failing
  checkPhase = "";
  postUnpack = let grinwebwallet = fetchurl {
     url = "https://github.com/mimblewimble/grin-web-wallet/releases/download/0.3.0.1/grin-web-wallet.tar.gz";
     sha256 = "1jcicswcz9vn6viwxzrv5pygdarr8rwkj842q57w1anlz35mw06n";
  };
  in ''
    (cd source; patch -p1 < ${./grin.diff})
    gzip -cd ${grinwebwallet} > /tmp/wallet.tar'';

  # Needed for tests
  LIBCLANG_PATH = "${llvmPackages.clang-unwrapped.lib}/lib";

  meta = {
    description = "Grin Mimblewimble node";
    homepage = https://grin-tech.org/;
    license = lib.licenses.asl20;
    broken = true;
  };
})
