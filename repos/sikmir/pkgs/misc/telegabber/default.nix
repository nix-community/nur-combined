{ lib, buildGoModule, fetchFromGitea, openssl, tdlib, zlib }:

buildGoModule rec {
  pname = "telegabber";
  version = "1.1.3";

  src = fetchFromGitea {
    domain = "dev.narayana.im";
    owner = "narayana";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-QGe3sUalYfh1tb2gUDkXw9O0khMg0g8LwGJssDaz5nk=";
  };

  vendorSha256 = "sha256-rRP3+HVc18VycJazJsmU1WOOo3m4fRLfouywTlXZVr8=";

  postPatch = ''
    substituteInPlace telegram/utils_test.go \
      --replace "TestOnlineOfflineAway" "SkipOnlineOfflineAway"
  '';

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
