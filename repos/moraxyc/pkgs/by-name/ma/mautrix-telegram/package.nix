{
  lib,
  stdenv,
  sources,
  source ? sources.mautrix-telegram,
  buildGoModule,

  olm,
  withGoOlm ? false,
}:

buildGoModule (finalAttrs: {
  pname = "mautrix-telegram";

  inherit (source) version src;

  # nix-update auto
  vendorHash = "sha256-+VDdJg5RZzMrphJ5SK+YbdENhPiHJpwGY/JqBJewtUo=";

  ldflags = [
    "-s"
    "-X 'main.Tag=v${finalAttrs.version}'"
    "-X 'main.Commit=${finalAttrs.src.rev}'"
    "-X 'main.BuildTime=1980-01-01T00:00:02Z'"
  ];

  buildInputs = [ stdenv.cc.cc.lib ] ++ lib.optional (!withGoOlm) olm;

  doCheck = false;

  tags = lib.optional withGoOlm "goolm";

  meta = {
    description = "Matrix-Telegram hybrid puppeting/relaybot bridge";
    homepage = "https://github.com/mautrix/telegram";
    license = lib.licenses.agpl3Plus;
    mainProgram = "mautrix-telegram";
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
