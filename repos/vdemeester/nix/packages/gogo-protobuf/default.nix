{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "gogo-protobuf-${version}";
  version = "1.3.1";
  rev = "v${version}";

  subPackages = [
    "proto"
    "gogoproto"
    "gogoreplace"
    "jsonpb"
    "protoc-gen-combo"
    "protoc-gen-gofast"
    "protoc-gen-gogo"
    "protoc-gen-gogofast"
    "protoc-gen-gogofaster"
    "protoc-gen-gogoslick"
    "protoc-gen-gogotypes"
    "protoc-gen-gostring"
    "protoc-min-version"
  ];

  src = fetchFromGitHub {
    inherit rev;
    owner = "gogo";
    repo = "protobuf";
    sha256 = "0x77x64sxjgfhmbijqfzmj8h4ar25l2w97h01q3cqs1wk7zfnkhp";
  };
  vendorHash = "0vkpqdd4x97cl3dm79mh1vic1ir4i20wv9q52sn13vr0b3kja0qy";
  modHash = "${vendorHash}";

}
