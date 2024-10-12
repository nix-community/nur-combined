# https://github.com/awslabs/llrt/releases/tag/v0.1.10-beta
{ fetchurl
, lib
, stdenvNoCC
, unzip
}:
let
  arch = if stdenvNoCC.isAarch64 then "arm64" else "x64";
  os = if stdenvNoCC.isDarwin then "darwin" else "linux";
  sha256Map = {
    "darwin-arm64" = "1gr37czvcc5w9p291q0ac8kb0nnmgyavnnwy9bjmlhskr5svjylr";
    "darwin-x64" = "0falxrp8v3kjfmasirrp6d7lmfdnpxc64gf9zbjhhlshndafqvbw";
    "linux-arm64" = "0sqiiks1yv8a8kr5w4xhsk10fk6nvjl80h52fppjcd505mxfjkh0";
    "linux-x64" = "0kl6a7m7mpva4fff69vr90x5m33yk2hyvxchzik9c5ii5ip2mpgh";
  };
  version = "0.1.10-beta";
in
stdenvNoCC.mkDerivation {
  pname = "llrt";
  version = version;
  src = fetchurl {
    url = "https://github.com/awslabs/llrt/releases/download/v${version}/llrt-${os}-${arch}.zip";
    sha256 = lib.getAttr "${os}-${arch}" sha256Map;
  };
  buildInputs = [ unzip ];
  unpackPhase = "unzip $src";
  installPhase = ''
    mkdir -p $out/bin
    cp llrt $out/bin/llrt
  '';
}
