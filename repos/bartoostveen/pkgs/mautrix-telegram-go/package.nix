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
  version = "0.2607.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "telegram";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MpdsWtEsVnC6purF5sw+RD+Nb/3Wo0xrzSn2BuFZmj8=";
  };

  vendorHash = "sha256-bmpTm1/6Z+kAFGAJ70ohBz8+n8JZk7mZyCfX0+FB/fE=";

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
