{
  config,
  lib,
  inputs,
  vaculib,
  vacuModuleType,
  vacuModules,
  ...
}:
let
  inherit (lib) mkOption types;
  expectedModuleTypes = [
    "nixos"
    "nix-on-droid"
    "plain"
  ];
in
if !builtins.elem vacuModuleType expectedModuleTypes then
  builtins.throw "error: unrecognized vacuModuleType ${builtins.toString vacuModuleType}"
else
  {
    imports = [
      vacuModules.packageSet
      vacuModules.systemKind
    ]
    ++ vaculib.directoryGrabberList ./.;
    options.vacu = {
      rootCAs = mkOption { type = types.listOf types.str; };
      hostName = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      shortHostName = mkOption {
        type = types.nullOr types.str;
        default = config.vacu.hostName;
        defaultText = "{option}`vacu.hostName`";
      };
      vnopnCA = mkOption {
        readOnly = true;
        type = types.str;
      };
    };
    config.vacu = {
      nix.caches = {
        vacu = {
          url = "https://nixcache.shelvacu.com/";
          keys = [ "nixcache.shelvacu.com:73u5ZGBpPRoVZfgNJQKYYBt9K9Io/jPwgUfuOLsJbsM=" ];
        };
        nix-community = {
          url = "https://nix-community.cachix.org/";
          keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
          enable = false;
        };
        nix-on-droid = {
          url = "https://nix-on-droid.cachix.org/";
          keys = [ "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU=" ];
          enable = false;
        };
        nixos = {
          url = "https://cache.nixos.org/";
          keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
        };
      };
      vnopnCA = ''
        -----BEGIN CERTIFICATE-----
        MIIBnjCCAUWgAwIBAgIBBTAKBggqhkjOPQQDAjAgMQswCQYDVQQGEwJVUzERMA8G
        A1UEAxMIdm5vcG4gQ0EwHhcNMjQwODEyMjExNTQwWhcNMzQwODEwMjExNTQwWjAg
        MQswCQYDVQQGEwJVUzERMA8GA1UEAxMIdm5vcG4gQ0EwWTATBgcqhkjOPQIBBggq
        hkjOPQMBBwNCAARqRbSeq00FfYUGeCHVkzwrjrydI56T12xy+iut0c4PemSuhyxC
        AgfdKYtDqMNZmSqMaLihzkBenD0bN5i0ndjho3AwbjAPBgNVHRMBAf8EBTADAQH/
        MCwGA1UdHgEB/wQiMCCgGDAKhwgKTkwA///8ADAKgggudDJkLmxhbqEEMAKBADAO
        BgNVHQ8BAf8EBAMCAQYwHQYDVR0OBBYEFAjSkbJQCQc1WP6nIP5iLDIKGFrdMAoG
        CCqGSM49BAMCA0cAMEQCIFtyawkZqFhvzgmqG/mYNNO6DdsQTPQ46x/08yrEiiF4
        AiA+FwAPqX+CBkaSdIhuhv1kIecmvacnDL5kpyB+9nDodw==
        -----END CERTIFICATE-----
      '';
      rootCAs = [ config.vacu.vnopnCA ];
      ssh.authorizedKeys = import inputs.vacu-keys;
    };
  }
