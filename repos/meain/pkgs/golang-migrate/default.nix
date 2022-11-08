{ tags, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "golang-migrate-${version}";
  version = "4.15.1";

  src = fetchFromGitHub {
    owner = "golang-migrate";
    repo = "migrate";
    rev = "v${version}";
    sha256 = "sha256-t4F4jvXexxCqKINaaczeG/B2vLSG87/qZ+VQitfAF4Y=";
  };

  subPackages = [ "cmd/migrate" ];
  vendorSha256 = "sha256-qgjU8mUdk8S0VHmWiTK/5euwhRQ4y3o4oRxG2EHF+7E=";
  inherit tags;
  ldflags = "-X main.Version=${version}";

  meta = with lib; {
    description = "Database migrations. CLI and Golang library.";
    homepage = "https://github.com/golang-migrate/migrate";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
