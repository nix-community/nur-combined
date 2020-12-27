{ lib, fetchurl, buildGoModule }:

buildGoModule rec {
  pname = "rmapi";
  version = "0.0.13";
  src = fetchurl {
    url = "https://github.com/juruen/rmapi/archive/v0.0.13.tar.gz";
    sha256 = "afaf438f0408af6fcadf73eb06b4c548ab678036eaf32bb825255e19f74a7157";
  };
  modSha256 = "1wh95iy72dzfzkbxr3yfbz6dcaddg7alf16158p7y43jflx3685d";
  vendorSha256 = "1pa75rjns1kknl2gmfprdzc3f2z8dk44jkz6dmf8f3prj0z7x88c";
  meta = {
    description = "Go app that allows you to access your reMarkable tablet files through the Cloud API";
    homepage = "https://github.com/juruen/rmapi";
    license = lib.licenses.agpl3;
  };
}
