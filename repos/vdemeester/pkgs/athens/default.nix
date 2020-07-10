{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "athens-${version}";
  version = "0.10.0";
  rev = "v${version}";

  goPackagePath = "github.com/gomods/athens";
  subPackages = [ "cmd/proxy" ];

  src = fetchFromGitHub {
    inherit rev;
    owner = "gomods";
    repo = "athens";
    sha256 = "10l96v2ayz3bp7kzr3a2lwyb95hc3dymlvcanl4629dy087ap6zj";
  };
  vendorSha256 = "1xgyna4hwwxjpwcd4k4npkzjlmzzhkba4f46vgcn3qzv0xysvpdx";
  modSha256 = "${vendorSha256}";

  meta = {
    description = "a Go module datastore and proxy";
    homepage = "https://github.com/godmods/athens";
    license = lib.licenses.mit;
  };
}
