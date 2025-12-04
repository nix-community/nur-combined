{
  config,
  lib,
  inputs,
  vacuModuleType,
  vacuModules,
  ...
}:
let
  inherit (lib) mkOption types;
  inherit (inputs) self;
  expectedModuleTypes = [
    "nixos"
    "nix-on-droid"
    "plain"
  ];
  anyRev = attrs: toString (attrs.rev or attrs.dirtyRev or "unk");
  anyShortRev = attrs: toString (attrs.shortRev or attrs.dirtyShortRev or "unk");
in
if !builtins.elem vacuModuleType expectedModuleTypes then
  builtins.throw "error: unrecognized vacuModuleType ${builtins.toString vacuModuleType}"
else
  {
    imports = [
      vacuModules.packageSet
      vacuModules.systemKind
      ../dns

      ./acmeDependencies.nix
      ./assertions.nix
      ./checks.nix
      ./common-but-not.nix
      ./git.nix
      ./hosts.nix
      ./hpn.nix
      ./lix.nix
      ./minimal-nixos.nix
      ./nixos.nix
      ./nixos-rebuild.nix
      ./nixvim.nix
      ./nix.nix
      ./nix-on-droid.nix
      ./packages.nix
      ./remap
      ./shell
      ./sops.nix
      ./sourceTree.nix
      ./staticNames.nix
      ./units-config.nix
      ./units-impl.nix
      ./verify-system
      ./thunderbird.nix
      ./fonts.nix
    ];
    options = {
      vacu.rootCAs = mkOption { type = types.listOf types.str; };
      vacu.versionId = mkOption {
        type = types.str;
        readOnly = true;
      };
      vacu.versionInfo = mkOption { readOnly = true; };
      vacu.hostName = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      vacu.shortHostName = mkOption {
        type = types.nullOr types.str;
        default = config.vacu.hostName;
        defaultText = "{option}`vacu.hostName`";
      };
      vacu.vnopnCA = mkOption {
        readOnly = true;
        type = types.str;
      };
    };
    config = {
      vacu.versionId = "${anyShortRev self}-${self.lastModifiedDate or "unk"}";
      vacu.versionInfo = {
        rev = anyRev self;
        inherit (self) lastModified lastModifiedDate;
        inherit (config.vacu) versionId;
        inherit vacuModuleType;
        inputRevs = lib.mapAttrs (_: v: anyRev v) inputs;
      }
      // lib.optionalAttrs (!config.vacu.isMinimal) {
        flakePath = self.outPath;
        inherit inputs;
      };

      vacu.nix.caches.vacu = {
        url = "https://nixcache.shelvacu.com/";
        keys = [ "nixcache.shelvacu.com:73u5ZGBpPRoVZfgNJQKYYBt9K9Io/jPwgUfuOLsJbsM=" ];
      };
      vacu.nix.caches.nix-community = {
        url = "https://nix-community.cachix.org/";
        keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
        enable = false;
      };
      vacu.nix.caches.nix-on-droid = {
        url = "https://nix-on-droid.cachix.org/";
        keys = [ "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU=" ];
        enable = false;
      };
      vacu.nix.caches.nixos = {
        url = "https://cache.nixos.org/";
        keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      };
      vacu.vnopnCA = ''
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
      vacu.rootCAs = [ config.vacu.vnopnCA ];

      vacu.ssh.authorizedKeys = import inputs.vacu-keys;
    };
  }
