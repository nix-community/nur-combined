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
  version = "0.2608.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "telegram";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EQ7c98GOaXaMcLF5xJfZ6tV+X9TKjNnd8a3ToJahNsE=";
  };

  vendorHash = "sha256-sh3CejNXhSLp2l4ZnfWwdwxqF+yzCn7/T4EWfVX84m8=";

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
