{ lib, buildGoModule, fetchFromGitea, openssl, tdlib, zlib, testers, telegabber }:

buildGoModule rec {
  pname = "telegabber";
  version = "1.8.2";

  src = fetchFromGitea {
    domain = "dev.narayana.im";
    owner = "narayana";
    repo = "telegabber";
    rev = "v${version}";
    hash = "sha256-dU+pqHKu9I/zSWqaM6gcZp9+ncyZAICi5y392tQoh9c=";
  };

  vendorHash = "sha256-AW4LycYBL5sSbZbn2sVsxq2k7dGBmwjXKnWgy3+dptI=";

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
  };
}
