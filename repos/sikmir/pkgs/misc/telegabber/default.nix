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
  version = "1.9.6";

  src = fetchFromGitea {
    domain = "dev.narayana.im";
    owner = "narayana";
    repo = "telegabber";
    tag = "v${version}";
    hash = "sha256-UkVuEgrRHDtC5Rkci87ecmvK4JyACFBplzecoIXM8vk=";
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
    homepage = "https://dev.narayana.im/narayana/telegabber";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    broken = true;
  };
}
