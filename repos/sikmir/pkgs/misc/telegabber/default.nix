{ lib, buildGoModule, fetchFromGitea, openssl, tdlib, zlib, testers, telegabber }:

buildGoModule rec {
  pname = "telegabber";
  version = "1.3.0";

  src = fetchFromGitea {
    domain = "dev.narayana.im";
    owner = "narayana";
    repo = "telegabber";
    rev = "v${version}";
    hash = "sha256-zctfACwvjgSI5EgXEZIRKCM4Jsjj9RtwJMbAq4vWV1M=";
  };

  vendorHash = "sha256-bh/+zEfZuk7l0t2didxlCnTObY3ThqsUXI8cD1oVeNk=";

  buildInputs = [ openssl tdlib zlib ];

  postInstall = ''
    install -Dm644 config_schema.json config.yml.example -t $out/share/telegabber
  '';

  passthru.tests.version = testers.testVersion {
    package = telegabber;
  };

  meta = with lib; {
    description = "XMPP/Jabber transport to Telegram network";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = true;
  };
}
