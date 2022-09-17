{ stdenv, lib, fetchFromGitHub, pkgs, rustPlatform }:
rustPlatform.buildRustPackage rec {
  pname = "cubeglobe-bot";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "DeeUnderscore";
    repo = "cubeglobe-bot";
    rev = "v${version}";
    sha256 = "00p7n4ycmaam8faivg55f272n0i1a68x60f87sa5vfn3nfkvn15f";
    fetchSubmodules = true;
  };

  cargoSha256 = "0f3mq47hp4zjripl3fn5vy8qhpy3sklkmz23vl4bvpbdb8h128l8";

  nativeBuildInputs = with pkgs; [
    pkgconfig
  ];

  buildInputs = with pkgs; [
    openssl_1_1
    SDL2
    SDL2_image
  ];

  doCheck = false;

  postInstall = ''
    mkdir -p $out/share/cubeglobe
    cp -R cubeglobe/assets $out/share/cubeglobe/
    substituteInPlace $out/share/cubeglobe/assets/full-tiles.toml --replace "assets/" "$out/share/cubeglobe/assets/"
  '';

  meta = with lib; {
    description = "Fediverse bot for posting randomly generated landscapes made of blocks";
    homepage = "https://github.com/DeeUnderscore/cubeglobe-bot/";
    license = licenses.isc;
  };
}