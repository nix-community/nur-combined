{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "athens-${version}";
  version = "0.11.0";
  rev = "v${version}";

  subPackages = [ "cmd/proxy" ];

  src = fetchFromGitHub {
    inherit rev;
    owner = "gomods";
    repo = "athens";
    sha256 = "sha256-hkewZ21ElkoDsbPPiCZNmWu4MBlKTlnrK72/xCX06Sk=";
  };
  vendorHash = "Hash-9iwT+PE54zy+DCJLb9R2YOXVYPqy3UGs+ro/2JoAFDU=";

  meta = {
    description = "a Go module datastore and proxy";
    homepage = "https://github.com/godmods/athens";
    license = lib.licenses.mit;
  };
}
