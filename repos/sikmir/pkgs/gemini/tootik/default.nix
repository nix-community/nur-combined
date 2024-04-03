{ lib, buildGoModule, fetchFromGitHub, openssl }:

buildGoModule rec {
  pname = "tootik";
  version = "0.9.6";

  src = fetchFromGitHub {
    owner = "dimkr";
    repo = "tootik";
    rev = version;
    hash = "sha256-RcuioFb0+mvZupwgaCN6qbcOy7gHp9KjJxRwaPI55yo=";
  };

  vendorHash = "sha256-/52VjfoecXaML1cDRIEe1EQPYU8xeP9lu4lY3cMV3VE=";

  nativeBuildInputs = [ openssl ];

  preBuild = ''
    go generate ./migrations
  '';

  ldflags = [ "-X github.com/dimkr/tootik/buildinfo.Version=${version}" ];

  tags = [ "netgo" "sqlite_omit_load_extension" "fts5" ];

  meta = with lib; {
    description = "A federated nanoblogging service with a Gemini frontend";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
  };
}
