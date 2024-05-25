{
  lib,
  buildGoModule,
  fetchFromGitea,
  openssl,
  tdlib,
  zlib,
  testers,
  telegabber,
}:

buildGoModule rec {
  pname = "telegabber";
  version = "1.9.5";

  src = fetchFromGitea {
    domain = "dev.narayana.im";
    owner = "narayana";
    repo = "telegabber";
    rev = "v${version}";
    hash = "sha256-PCCo271B/SIF9n/6ohG5sA8fQeLDtTIoovs09CXdRm0=";
  };

  vendorHash = "sha256-3qSa6yJXSjrmTIBrulCnZMZzqNtpkzpzWeYAzHl8uUM=";

  buildInputs = [
    openssl
    tdlib
    zlib
  ];

  postInstall = ''
    install -Dm644 config_schema.json config.yml.example -t $out/share/telegabber
  '';

  passthru.tests.version = testers.testVersion { package = telegabber; };

  meta = {
    description = "XMPP/Jabber transport to Telegram network";
    inherit (src.meta) homepage;
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
