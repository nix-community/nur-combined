{ system, stdenv, fetchurl }:
let
  clashSystems = {
    "aarch64-linux" = {
      system = "linux-armv8";
      sha256 = "1p1sh1vxv95x5wcg8536ymvy7lw1kyphi26mpz1m54k3b1hmzj97";
    };
    "i686-linux" = {
      system = "linux-386";
      sha256 = "1r5bgngcw6n66cxjzklin79zaqlkjd5wjmgp4shf2flk6qcifkc2";
    };
    "x86_64-darwin" = {
      system = "darwin-amd64";
      sha256 = "02nrz6m14zm5lkwi39czbyix3aj4lsw4bvq33i3g9g4482bx8mn5";
    };
    "x86_64-linux" = {
      system = "linux-amd64";
      sha256 = "1fxld2f9ki8yg423h4fbl5shr09j85kn6kkby8b5ngkk3585b48y";
    };
  };
  clashSystem = clashSystems.${system};
in
stdenv.mkDerivation rec {
  pname = "clash-premium";
  version = "2020.12.27";

  src = fetchurl {
    url = "https://github.com/Dreamacro/clash/releases/download/premium/clash-${clashSystem.system}-${version}.gz";
    sha256 = clashSystem.sha256;
  };

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/clash-premium.gz
    gzip --decompress $out/bin/clash-premium.gz
    chmod +x $out/bin/clash-premium
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/Dreamacro/clash;
    description = "Close-sourced pre-built Clash binary with TUN support and more";
    license = licenses.unfree;
    platforms = attrNames clashSystems;
  };
}
