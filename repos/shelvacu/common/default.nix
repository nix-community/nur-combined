{
  config,
  lib,
  inputs,
  vaculib,
  vacuModuleType,
  vacuModules,
  vacuRoot,
  ...
}:
let
  inherit (lib) mkOption types;
  expectedModuleTypes = [
    "nixos"
    "nix-on-droid"
    "plain"
    "dns"
  ];
in
if !builtins.elem vacuModuleType expectedModuleTypes then
  throw "error: unrecognized vacuModuleType ${toString vacuModuleType}"
else
  {
    imports = [
      vacuModules.packageSet
      vacuModules.systemKind
      vacuModules.expose
      vacuModules.environmentVariables
      /${vacuRoot}/common-nopkgs
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
