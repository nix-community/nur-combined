{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "lanotifica";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "alessandrolattao";
    repo = "lanotifica";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5vZoj0EiMvp+u4eE3F60h2DJJuK5ouWts29hgyIETyk=";
  };

  modRoot = "server";

  vendorHash = "sha256-wecelb1EUNDKSUAkdUl3gTBf9+YkfxefViuhfDcJyKo=";

  env.CGO_ENABLED = "0";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Mirror Android notifications to your Linux desktop over the local network";
    longDescription = ''
      LaNotifica forwards notifications from Android apps (WhatsApp, Telegram,
      calls and others) to a Linux desktop over the local network.

      The Go server advertises itself via mDNS, serves an HTTPS QR-code pairing
      page and relays incoming notifications to the desktop through the
      org.freedesktop.Notifications D-Bus interface.
    '';
    homepage = "https://github.com/alessandrolattao/lanotifica";
    changelog = "https://github.com/alessandrolattao/lanotifica/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ataraxiasjel ];
    mainProgram = "lanotifica";
    platforms = lib.platforms.linux;
  };
})
