{
  lib,
  sources,
  source ? sources.aliyundrive-webdav,

  python3,
  rustPlatform,

  openssl,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "aliyundrive-webdav";
  inherit (source) src version;

  pyproject = true;

  cargoDeps = rustPlatform.importCargoLock source.cargoLock."Cargo.lock";

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  buildInputs = [ openssl ];

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  meta = {
    description = "阿里云盘 WebDAV 服务";
    homepage = "https://github.com/messense/aliyundrive-webdav";
    changelog = "https://github.com/messense/aliyundrive-webdav/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "aliyundrive-webdav";
  };
})
