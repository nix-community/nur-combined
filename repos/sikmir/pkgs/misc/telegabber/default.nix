{
  lib,
  buildGoModule,
  fetchFromGitHub,
  fetchFromGitea,
  openssl,
  tdlib,
  zlib,
  testers,
}:

let
  tdlib' = tdlib.overrideAttrs (
    oa: fa: {
      version = "1.8.23-unstable-2024-01-23";
      src = fetchFromGitHub {
        owner = "tdlib";
        repo = "td";
        rev = "5bbfc1cf5dab94f82e02f3430ded7241d4653551";
        hash = "sha256-gd9xHXVFEs7KkvXRvPJQZlKnBCxdvh67VX/sfeFZXf4=";
      };
    }
  );
in
buildGoModule (finalAttrs: {
  pname = "telegabber";
  version = "1.12.4";

  src = fetchFromGitea {
    domain = "dev.narayana.im";
    owner = "narayana";
    repo = "telegabber";
    tag = "v${finalAttrs.version}";
    hash = "sha256-//S4bh2H747059KqDQNWA4lpH3OXPzl+OndGY7WNwg8=";
    forceFetchGit = true;
  };

  vendorHash = "sha256-qiPMQuk1fUx7GFlJUu71n2pLVqd7vUPnRva3p/iDkr4=";

  buildInputs = [
    openssl
    tdlib'
    zlib
  ];

  postInstall = ''
    install -Dm644 config_schema.json config.yml.example -t $out/share/telegabber
  '';

  checkFlags = [ "-skip=TestSessionToMap" ];

  passthru.tests.version = testers.testVersion { package = finalAttrs.finalPackage; };

  meta = {
    description = "XMPP/Jabber transport to Telegram network";
    homepage = "https://dev.narayana.im/narayana/telegabber";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "telegabber";
  };
})
