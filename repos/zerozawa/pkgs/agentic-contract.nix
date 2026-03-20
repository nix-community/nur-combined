{
  fetchFromGitHub,
  lib,
  rustPlatform,
}: let
  rev = "0f01fc38b490c0ac289019c188b716c34060361f";
  commonMeta = with lib; {
    homepage = "https://github.com/agentralabs/agentic-contract";
    license = with licenses; [mit];
    mainProgram = "acon";
    platforms = platforms.linux ++ platforms.darwin;
    sourceProvenance = with sourceTypes; [fromSource];
  };
in
  rustPlatform.buildRustPackage rec {
    pname = "agentic-contract";
    version = "0-unstable-${builtins.substring 0 7 rev}";

    src = fetchFromGitHub {
      owner = "agentralabs";
      repo = pname;
      inherit rev;
      hash = "sha256-c/AC1Mi791SMCGtTfOtm+8lS2MTMqxuiNUAKJ9J6SsA=";
    };

    cargoHash = "sha256-0p+aq72ElDbi4lOzlbmaPWDA7OJIp3fWRQEc6pWM2RE=";

    cargoBuildFlags = [
      "-p"
      "agentic-contract-cli"
    ];

    cargoTestFlags = cargoBuildFlags;

    passthru = {
      mcp = rustPlatform.buildRustPackage rec {
        inherit src version cargoHash;
        pname = "agentic-contract-mcp";
        cargoBuildFlags = [
          "-p"
          pname
        ];
        cargoTestFlags = cargoBuildFlags;
        checkFlags = [
          "--skip=test_transport_write_framing"
          "--skip=test_write_empty_message"
          "--skip=test_write_framing_correct"
          "--skip=test_write_multiple_messages"
          "--skip=test_write_read_roundtrip"
          "--skip=test_write_unicode_message"
        ];
        cargoInstallFlags = [
          "-p"
          pname
          "--bin"
          pname
        ];
        meta =
          commonMeta
          // {
            description = "MCP server for AgenticContract";
          };
      };
    };

    cargoInstallFlags = [
      "-p"
      "agentic-contract-cli"
      "--bin"
      "acon"
    ];

    meta =
      commonMeta
      // {
        description = "Policy engine CLI for AI agents";
      };
  }
