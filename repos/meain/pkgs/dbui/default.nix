{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "dbui";
  version = "0.7.0";
  owner = "KenanBek";

  src = fetchFromGitHub {
    inherit owner;
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-HBv+58uSPdNK8S41QuU8/Y3AbBEGdRntdRe4Pfy1GCo=";
  };

  vendorSha256 = "sha256-lBbLrK5P5KrrOZAOLvGKBJyzSk3bINd8aNgHPMmOyEw=";
  proxyVendor = true;

  meta = with lib; {
    description = "Universal Database CLI for MySQL, PostgreSQL, and SQLite. Terminal User Interface Application.";
    license = lib.licenses.asl20;
    homepage = "https://github.com/${owner}/${pname}";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
