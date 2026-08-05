{
  lib,
  vacupkglib,
  vacuPlainEval,

  writers,
  age,
  ssh-to-age,
  shellvaculib,
  sops,
  ...
}:
let
  plainEval = vacuPlainEval;
  # getBuildBuild = drv: (drv.__spliced.buildBuild or drv);
  getBuildBuild = x: x;
  sshToAge =
    sshPubText:
    vacupkglib.outputOf {
      name = "age-from-ssh.txt";
      cmd = ''printf '%s' ${lib.escapeShellArg sshPubText} | ${lib.getExe (getBuildBuild ssh-to-age)} > "$out"'';
    };
  userKeys = lib.attrValues plainEval.config.vacu.ssh.authorizedKeys;
  userKeysAge = map sshToAge userKeys;
  agesOf = hostname: map sshToAge plainEval.config.vacu.hosts.${hostname}.ssh.keys;
  singleGroup = keys: [ { age = keys; } ];
  testAgeSecret = "AGE-SECRET-KEY-1QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQPQQ94XCHF";
  testAgePublic = vacupkglib.outputOf {
    name = "test-age-public-key.txt";
    cmd = ''printf '%s' ${lib.escapeShellArg testAgeSecret} | ${lib.getExe' "age-keygen" (getBuildBuild age)} -y > "$out"'';
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
        path_regex = "/secrets/hosts/prophecy\\.yaml$";
        key_groups = singleGroup (userKeysAge ++ agesOf "prophecy");
      }
      {
        path_regex = "/secrets/hosts/quasar2\\.yaml$";
        key_groups = singleGroup (userKeysAge ++ agesOf "quasar2");
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
        key_groups = singleGroup (userKeysAge ++ agesOf "prophecy" ++ agesOf "solis");
      }
      {
        path_regex = "/secrets/dynamic-dns\\.yaml$";
        key_groups = singleGroup (userKeysAge ++ agesOf "prophecy");
      }
    ];
  };
  sopsConfigFile = writers.writeYAML "sops.yaml" sopsConfig;
in
(writers.writeBashBin "vacuWrappedSops" ''
  source ${shellvaculib.file} || exit 1
  declare -a age_keys=()
  age_keys+=(${lib.escapeShellArg testAgeSecret})

  if [[ -n ''${SOPS_AGE_KEY:-} ]]; then
    declare -a existing_keys=()
    mapfile -t existing_keys
    declare k=""
    for k in "''${existing_keys[@]}"; do
      if [[ -n $k ]]; then
        age_keys+=("$k")
      fi
    done
  fi

  function process_line() {
    declare config_line="$1"

    if [[ $config_line != "identityfile "* ]]; then
      return 0
    fi

    declare filename="''${config_line#identityfile }"
    filename="''${filename/#\~/$HOME}"
    
    if ! [[ -f $filename ]]; then
      return 0
    fi

    declare keygen_info=""
    keygen_info="$(ssh-keygen -l -f "$filename")"

    if [[ $keygen_info != *" (ED25519)" ]]; then
      return 0
    fi

    declare age_key=""
    age_key="$(${lib.getExe ssh-to-age} -private-key < "$filename")"
    age_keys+=("$age_key")
  }

  declare ssh_config
  if ! ssh_config="$(ssh -G nonexistantdomain.example)"; then
    svl_err "warn: failed to run ssh"
  else
    declare -a config_lines=()
    mapfile -t config_lines <<<"$ssh_config"
    declare line=""
    for line in "''${config_lines[@]}"; do
      process_line "$line"
    done
  fi

  declare -x SOPS_AGE_KEY=""
  printf -v SOPS_AGE_KEY '%s\n' "''${age_keys[@]}"
  SOPS_AGE_KEY="''${SOPS_AGE_KEY%$'\n'}"
  ${lib.getExe sops} --config ${lib.escapeShellArg sopsConfigFile} "$@"
'').overrideAttrs
  (oldAttrs: {
    passthru = (oldAttrs.passthru or { }) // {
      inherit sopsConfig sopsConfigFile;
    };
  })
