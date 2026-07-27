{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "protobuild-unstable-${version}";
  version = "2020-04-14";
  rev = "324b1750ca060b814b18f4142b544b292d42968e";

  src = fetchFromGitHub {
    inherit rev;
    owner = "stevvooe";
    repo = "protobuild";
    sha256 = "0v3biryf56hscg7s8mm9ds8zypajb976z6x4xlhx1852wz6vqfxh";
  };
  vendorHash = "19wazsl2k8563k96w75lcfdvvz4k5l5kg8inbm1hkh1h0knnzh8r";
  modHash = "${vendorHash}";

  meta = {
    description = "Build protobufs in Go, easily";
    homepage = https://github.com/stevvooe/protobuild;
    license = lib.licenses.asl20;
  };
}
