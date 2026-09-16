{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  olm,
  withGoOlm ? false,
}:

buildGoModule (finalAttrs: {
  pname = "mautrix-telegram";
  version = "0.2609.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "telegram";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M8kQap14MRh3tlqOe7JxLkJlsNsJY/COztv0AqvdgF0=";
  };

  vendorHash = "sha256-qW/v/QmhQRF2SAMUNXE2mfVGVEp+DU3gESWVRKHqfGM=";

  ldflags = [
    "-X"
    "main.Tag=v${finalAttrs.version}"
  ];

  buildInputs = (lib.optional (!withGoOlm) olm) ++ [ stdenv.cc.cc.lib ];

  doCheck = false;
  doInstallCheck = false;

  tags = lib.optional withGoOlm "goolm";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A Matrix-Telegram puppeting bridge";
    homepage = "https://github.com/mautrix/telegram";
    changelog = "https://github.com/mautrix/telegram/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "mautrix-telegram";
    platforms = lib.platforms.all;
  };
})
