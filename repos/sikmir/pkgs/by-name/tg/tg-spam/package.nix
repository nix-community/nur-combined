{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "tg-spam";
  version = "1.26.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "umputun";
    repo = "tg-spam";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5hQhl6Q7q+vVO5sOoEUHamfFBp7E7/CwzSImYbCVdEg=";
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
