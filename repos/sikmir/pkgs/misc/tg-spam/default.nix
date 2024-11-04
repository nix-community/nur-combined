{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "tg-spam";
  version = "1.14.1";

  src = fetchFromGitHub {
    owner = "umputun";
    repo = "tg-spam";
    rev = "v${version}";
    hash = "sha256-qx53EdHGp1JvOV4dvkQ7/pK8L+y2uurWgNdm0DEhOuE=";
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
