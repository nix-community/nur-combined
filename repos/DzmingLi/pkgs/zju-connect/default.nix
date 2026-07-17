{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  pkg-config,
  stdenv,
}:
buildGoModule (finalAttrs: {
  pname = "zju-connect";
  version = "1.2.1";
  src = fetchFromGitHub {
    owner = "Mythologyli";
    repo = "zju-connect";
    rev = "v${finalAttrs.version}";
    hash = "sha256-TdXO/dK41zTR00BCOB3TcMTiip2XBSjNx024WpiIT0Q=";
  };
  vendorHash = "sha256-lDxroSrPwwYF2w7qXR+PQYkre8E+nOwPzDiMoeScjO0=";

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

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "zju-connect";
    description = "SSL VPN client based on EasierConnect";
    homepage = "https://github.com/Mythologyli/zju-connect";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
  };
})
