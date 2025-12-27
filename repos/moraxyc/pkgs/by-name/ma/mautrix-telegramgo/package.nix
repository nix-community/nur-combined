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
  vendorHash = "sha256-omdO+9PpeiCSr5XmWq9i7MICmBiwOioBzIshRk2jib0=";

  buildInputs = [ olm ];

  # nix-update auto

  meta = {
    description = "Go rewrite of mautrix-telegram";
    homepage = "https://github.com/mautrix/telegramgo";
    license = lib.licenses.agpl3Plus;
    mainProgram = "mautrix-telegram";
    maintainers = with lib.maintainers; [ moraxyc ];
  };
}
