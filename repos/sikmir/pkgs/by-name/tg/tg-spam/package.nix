{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "tg-spam";
  version = "1.25.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "umputun";
    repo = "tg-spam";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RLI32q7AKJPyGbMVUdP4qH7SV/UkWDUivGJPzvoy+0Q=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
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
