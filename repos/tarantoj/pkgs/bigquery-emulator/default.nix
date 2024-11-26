{
  buildGoModule,
  pkgs,
  fetchFromGitHub,
  lib,
}: let
  version = "0.6.5";
  pname = "bigquery-emulator";
in
  buildGoModule.override {
    stdenv = pkgs.clangStdenv;
  } {
    name = pname;
    src = fetchFromGitHub {
      owner = "goccy";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-uYWAZw/4IOH5FVwPO9mtPhwG2D6HsVkScXmKsxtD2gY=";
    };

    # proxyVendor = true;

    # buildInputs = [mcl bls];
    # subPackage = ["internal/cmd/generator"];

    # vendorHash = "sha256-kigjb0IYpoOtQ3SIFTbuJQMyP6/Ao4bk0fZ6TPkP6DE=";
    vendorHash = "sha256-TQlsivudutyPFW+3HHX7rYuoB5wafmDTAO1TElO/8pc=";
    postPatch = ''
      # main module (github.com/ipfs/ipget) does not contain package github.com/ipfs/ipget/sharness/dependencies
      rm -r internal/cmd/generator
    '';

    ldflags = ["-s -w -X main.version=${version} -X main.revision=v${version}"];
    doCheck = false;

    meta = with lib; {
      description = "BigQuery emulator server implemented in Go.";
      homepage = "https://github.com/goccy/bigquery-emulator";
      changelog = "https://github.com/goccy/pname/releases/tag/v${version}";
      license = licenses.mit;
      mainProgram = "bigquery-emulator";
    };
  }
