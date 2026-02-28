{
  buildGoModule,
  fetchFromGitHub,
  lib,
  pkg-config,
  stdenv,
}:
buildGoModule (finalAttrs: {
  pname = "zju-connect";
  version = "0.9.0";
  src = fetchFromGitHub {
    owner = "Mythologyli";
    repo = "zju-connect";
    rev = "v${finalAttrs.version}";
    hash = "sha256-LrupxRFobVzzOiQCznnaIH17sTsnzjiMVnWDMyN0dwY=";
  };
  vendorHash = "sha256-G+glwXw3zDA4XYWUnrkyG55PicHDutXRe7ZzdJGirZA=";

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    mainProgram = "zju-connect";
    description = "SSL VPN client based on EasierConnect";
    homepage = "https://github.com/Mythologyli/zju-connect";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
  };
})
