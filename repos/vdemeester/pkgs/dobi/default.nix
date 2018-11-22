{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "dobi-${version}";
  version = "0.12.0";
  rev = "v${version}";

  buildFlagsArray = let t = "${goPackagePath}/cmd"; in ''
    -ldflags=
       -X ${t}.gitsha=${rev}
       -X ${t}.buildDate=unknown
  '';
  goPackagePath = "github.com/dnephin/dobi";
  excludedPackages = "docs";

  src = fetchFromGitHub {
    inherit rev;
    owner = "dnephin";
    repo = "dobi";
    sha256 = "0jrq032vzpv2pgdfhagcg01xwfkpsp9j769j54pjvc2mnxmc1cpj";
  };

  goDeps = ./deps.nix;

  meta = {
    description = "A build automation tool for Docker applications";
    homepage = https://dnephin.github.io/dobi/;
    license = lib.licenses.asl20;
  };
}
