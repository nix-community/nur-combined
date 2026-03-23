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
  vendorHash = "sha256-KhhEvbCrDUZ1+01YtL+QOt5QzeCsvxwkVRfhRnAdhiI=";

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
