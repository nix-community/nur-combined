{ stdenv, lib, buildGoModule }:

buildGoModule rec {
  name = "bus";
  src = ./.;

  vendorSha256 = "1633qy8a24pacr337v20ws12p3wgr2kf7q2mymar90qrq301wfnx";
  modSha256 = "${vendorSha256}";
}
