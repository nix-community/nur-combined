{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "tg-spam";
  version = "1.27.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "umputun";
    repo = "tg-spam";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sgidUvxArOT03sOw5hveRr8gaQts0CTk0P1Yk3g2m6U=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-X main.revision=${finalAttrs.version}"
  ];

  postInstall = ''
    mv $out/bin/{app,tg-spam}
  '';

  doCheck = false;

  meta = {
    description = "Anti-Spam bot for Telegram and anti-spam library";
    homepage = "https://tg-spam.umputun.dev/";
    license = lib.licenses.mit;
    mainProgram = "tg-spam";
    maintainers = [ lib.maintainers.sikmir ];
  };
})
