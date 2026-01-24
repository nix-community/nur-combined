{
  lib,
  sources,
  source ? sources.mautrix-telegramgo,
  buildGoModule,

  olm,
}:

buildGoModule {
  pname = "mautrix-telegram";

  inherit (source) version src;
  vendorHash = "sha256-cbxIXZCzK2mScQSL+/byBb5IM2MO28IEfu3cuY7AQOw=";

  buildInputs = [ olm ];

  # nix-update auto
  doCheck = false;

  meta = {
    description = "Go rewrite of mautrix-telegram";
    homepage = "https://github.com/mautrix/telegramgo";
    license = lib.licenses.agpl3Plus;
    mainProgram = "mautrix-telegram";
    maintainers = with lib.maintainers; [ moraxyc ];
  };
}
