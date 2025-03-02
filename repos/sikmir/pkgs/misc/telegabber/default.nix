{
  lib,
  buildGoModule,
  fetchFromGitHub,
  fetchFromGitea,
  openssl,
  tdlib,
  zlib,
  testers,
  telegabber,
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
buildGoModule rec {
  pname = "telegabber";
  version = "1.9.7";

  src = fetchFromGitea {
    domain = "dev.narayana.im";
    owner = "narayana";
    repo = "telegabber";
    tag = "v${version}";
    hash = "sha256-UrfTPYZMfYZcmE4bLyUZ8mCgvj2IF6AA+8f6ToNhsvU=";
    forceFetchGit = true;
  };

  vendorHash = "sha256-3qSa6yJXSjrmTIBrulCnZMZzqNtpkzpzWeYAzHl8uUM=";

  buildInputs = [
    openssl
    tdlib'
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
  };
}
