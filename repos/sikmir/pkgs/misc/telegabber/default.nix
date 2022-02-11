{ lib, buildGoModule, fetchFromGitea, openssl, tdlib, zlib }:

buildGoModule rec {
  pname = "telegabber";
  version = "1.1.0";

  src = fetchFromGitea {
    domain = "dev.narayana.im";
    owner = "narayana";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-iwJ3QjJ2KjKneuaWRcOZ7ji7tgh1I92CWkKjLnCVMPw=";
  };

  vendorSha256 = "sha256-rRP3+HVc18VycJazJsmU1WOOo3m4fRLfouywTlXZVr8=";

  buildInputs = [ openssl tdlib zlib ];

  postInstall = ''
    install -Dm644 config_schema.json config.yml.example -t $out/share/telegabber
  '';

  meta = with lib; {
    description = "XMPP/Jabber transport to Telegram network";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
