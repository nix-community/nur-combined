{ pkgs ? import <nixpkgs> {}, lib }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "coordsfinder";
  version = "1.2.1";

  src = pkgs.fetchFromGitHub {
    owner = "ALaggyDev";
    repo = "CoordsFinder";
    rev = "86bf48e47d668e43591b2b76cd713c15492d7e64";
    hash = "sha256-ErO5UyNpF0C9fiqEVQLfDZVQB1LLIsZelMsdLySdWDM=";
  };

  cargoHash = "sha256-I9g+QT2+gMpS0WrIG/I+XU/ztsNaAv3Gw9fZM5jDIis=";

  nativeBuildInputs = with pkgs; [
    pkg-config
    makeWrapper
  ];

  buildInputs = with pkgs; [
    openssl
  ];


  postInstall = ''
    wrapProgram $out/bin/coordsfinder \
      --prefix LD_LIBRARY_PATH : "${pkgs.vulkan-loader}/lib:/run/opengl-driver/lib"
  '';

  meta = {
    description = "Minecraft's Fastest Texture Rotation Cracker";
    homepage = "https://github.com/ALaggyDev/CoordsFinder";
    license = lib.licenses.mit;
    mainProgram = "coordsfinder";
    platforms = lib.platforms.linux;
  };
}