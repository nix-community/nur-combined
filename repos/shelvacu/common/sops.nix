{
  lib,
  pkgs,
  config,
  vaculib,
  vacupkglib,
  ...
}:
let
  ssh-to-age = lib.getExe pkgs.ssh-to-age;
  sshToAge =
    sshPubText:
    vacupkglib.outputOf {
      name = "age-from-ssh.txt";
      cmd = ''printf '%s' ${lib.escapeShellArg sshPubText} | ${ssh-to-age} > "$out"'';
    };
  userKeys = lib.attrValues config.vacu.ssh.authorizedKeys;
  userKeysAge = map sshToAge userKeys;
  agesOf = hostname: map sshToAge config.vacu.hosts.${hostname}.sshKeys;
  singleGroup = keys: [ { age = keys; } ];
  testAgeSecret = "AGE-SECRET-KEY-1QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQPQQ94XCHF";
  testAgePublic = vacupkglib.outputOf {
    name = "test-age-public-key.txt";
    cmd = ''printf '%s' ${lib.escapeShellArg testAgeSecret} | ${pkgs.age}/bin/age-keygen -y > "$out"'';
  };
  sopsConfig = {
    creation_rules = [
      {
        path_regex = "/secrets/misc/[^/]+$";
        key_groups = singleGroup userKeysAge;
      }
      {
        path_regex = "/secrets/hosts/liam\\.yaml$";
        key_groups = singleGroup (userKeysAge ++ agesOf "liam");
      }
      {
        path_regex = "/secrets/hosts/triple-dezert\\.yaml$";
        key_groups = singleGroup (userKeysAge ++ agesOf "triple-dezert");
      }
      {
        path_regex = "/secrets/hosts/prophecy\\.yaml$";
        key_groups = singleGroup (userKeysAge ++ agesOf "prophecy");
      }
      {
        path_regex = "/secrets/hosts/solis\\.yaml$";
        key_groups = singleGroup (userKeysAge ++ agesOf "solis");
      }
      {
        path_regex = "/secrets/solis-oauth\\.yaml$";
        key_groups = singleGroup (userKeysAge ++ agesOf "solis" ++ agesOf "prophecy");
      }
      {
        path_regex = "/secrets/radicle-private\\.key$";
        key_groups = singleGroup (userKeysAge ++ agesOf "fw");
      }
      {
        path_regex = "/secrets/garage-rpc\\.key$";
        key_groups = singleGroup (
          userKeysAge ++ agesOf "triple-dezert" ++ agesOf "prophecy" ++ agesOf "solis"
        );
      }
      {
        path_regex = "/secrets/dynamic-dns\\.yaml$";
        key_groups = singleGroup (userKeysAge ++ agesOf "triple-dezert" ++ agesOf "prophecy");
      }
      {
        path_regex = "/tests/triple-dezert/test_secrets/";
        key_groups = singleGroup [ testAgePublic ];
      }
    ];
  };
  sopsConfigFile = pkgs.writers.writeYAML "sops.yaml" sopsConfig;
  wrappedSops = vacupkglib.makeWrapper {
    original = lib.getExe pkgs.sops;
    new = "vacu-nix-stuff-sops";
    add_flags = [
      "--config"
      sopsConfigFile
    ];
    run = lib.singleton ''
      set -e
      age_keys=("${testAgeSecret}" "$(cat $HOME/.ssh/id_ed25519 | ${lib.getExe pkgs.ssh-to-age} -private-key)")

      export SOPS_AGE_KEY
      printf -v SOPS_AGE_KEY "%s\n" "''${age_keys[@]}"
      # declare -p SOPS_AGE_KEY
    '';
  };
in
{
  options.vacu.sopsConfigFile = vaculib.mkOutOption sopsConfigFile;
  options.vacu.wrappedSops = vaculib.mkOutOption wrappedSops;
}
