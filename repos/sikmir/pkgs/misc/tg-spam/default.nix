{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "tg-spam";
  version = "1.18.0";

  src = fetchFromGitHub {
    owner = "umputun";
    repo = "tg-spam";
    tag = "v${version}";
    hash = "sha256-lGYE5ixrWpqjQ0IEv6SK9S2cn81MtLPLstyG5psm2TQ=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
    "-X main.revision=${version}"
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
}
