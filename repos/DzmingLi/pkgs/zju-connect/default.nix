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
  version = "1.2.2";
  src = fetchFromGitHub {
    owner = "Mythologyli";
    repo = "zju-connect";
    rev = "v${finalAttrs.version}";
    hash = "sha256-eTBAoU39Wv+vKPU2uzz0A4ecCEahvkW4H8EqnHQ51Og=";
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
