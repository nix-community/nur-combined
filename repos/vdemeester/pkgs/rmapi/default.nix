{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "rmapi-${version}";
  version = "0.0.12";
  rev = "v${version}";

  goPackagePath = "github.com/juruen/rmapi";

  src = fetchFromGitHub {
    inherit rev;
    owner = "juruen";
    repo = "rmapi";
    sha256 = "049m0p4wbsl822iym8xmc938d4k90iw7wjdzcxfyy8d27hv9mp45";
  };
  vendorSha256 = "0w2qiafs5gkgv00yz16bx8yis6gnpxbgqliwrhj5k6z8yy9s7b17";
  modSha256 = "${vendorSha256}";

  meta = {
    description = "Go app that allows you to access your reMarkable tablet files through the Cloud API";
    homepage = "https://github.com/juruen/rmapi";
    license = lib.licenses.gpl3;
  };
}
