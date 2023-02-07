{ config, lib, ... }:
with lib;
let
  cfg = config.age;
  inherit (cfg) ageBin;
  newGeneration = ''
    _agenix_generation="$(basename "$(readlink ${cfg.secretsDir})" || echo 0)"
    (( ++_agenix_generation ))
    echo "[agenix] creating new generation in ${cfg.secretsMountPoint}/$_agenix_generation"
    mkdir -p "${cfg.secretsMountPoint}"
    chmod 0751 "${cfg.secretsMountPoint}"
    grep -q "${cfg.secretsMountPoint} ramfs" /proc/mounts || mount -t ramfs none "${cfg.secretsMountPoint}" -o nodev,nosuid,mode=0751
    mkdir -p "${cfg.secretsMountPoint}/$_agenix_generation"
    chmod 0751 "${cfg.secretsMountPoint}/$_agenix_generation"
  '';

  identities =
    builtins.concatStringsSep " " (map (path: "-i ${path}") cfg.identityPaths);

  setTruePath = secretType: ''
    ${if secretType.symlink then ''
      _truePath="${cfg.secretsMountPoint}/$_agenix_generation/${secretType.name}"
    '' else ''
      _truePath="${secretType.path}"
    ''}
  '';

  installSecret = secretType: ''
    ${setTruePath secretType}
    echo "decrypting '${secretType.file}' to '$_truePath'..."
    TMP_FILE="$_truePath.tmp"
    mkdir -p "$(dirname "$_truePath")"
    [ "${secretType.path}" != "${cfg.secretsDir}/${secretType.name}" ] && mkdir -p "$(dirname "${secretType.path}")"
    (
      umask u=r,g=,o=
      test -f "${secretType.file}" || echo '[agenix] WARNING: encrypted file ${secretType.file} does not exist!'
      test -d "$(dirname "$TMP_FILE")" || echo "[agenix] WARNING: $(dirname "$TMP_FILE") does not exist!"
      LANG=${config.i18n.defaultLocale} ${ageBin} --decrypt ${identities} -o "$TMP_FILE" "${secretType.file}"
    )
    chmod ${secretType.mode} "$TMP_FILE"
    mv -f "$TMP_FILE" "$_truePath"
    ${optionalString secretType.symlink ''
      [ "${secretType.path}" != "${cfg.secretsDir}/${secretType.name}" ] && ln -sfn "${cfg.secretsDir}/${secretType.name}" "${secretType.path}"
    ''}
  '';

  testIdentities = map (path: ''
    test -f ${path} || echo '[agenix] WARNING: config.age.identityPaths entry ${path} not present!'
  '') cfg.identityPaths;

  cleanupAndLink = ''
    _agenix_generation="$(basename "$(readlink ${cfg.secretsDir})" || echo 0)"
    (( ++_agenix_generation ))
    echo "[agenix] symlinking new secrets to ${cfg.secretsDir} (generation $_agenix_generation)..."
    ln -sfn "${cfg.secretsMountPoint}/$_agenix_generation" ${cfg.secretsDir}
    (( _agenix_generation > 1 )) && {
    echo "[agenix] removing old secrets (generation $(( _agenix_generation - 1 )))..."
    rm -rf "${cfg.secretsMountPoint}/$(( _agenix_generation - 1 ))"
    }
  '';

  installSecrets = builtins.concatStringsSep "\n"
    ([ "echo '[agenix] decrypting secrets...'" ] ++ testIdentities
      ++ (map installSecret (builtins.attrValues cfg.secrets))
      ++ [ cleanupAndLink ]);
  # On microVMs, the attempt to decrypt age encrypted files 
  # happens far too early in the boot process. This leads to a downstream
  # failure of anything depending on it as the mounts for the virtual filesystems
  # occur much later and agenix doesn't attempt to resolve this. (to be fair,
  # one hell of an edge case)

  # TODO: Add a systemd unit below to agenix options that would then attempt to
  # decrypt the secrets later in the boot.
  # This should also look for if tailscale is enalbed and create a depends on 
  # for tailscale to await completion of the decryption.
in {

  systemd.services."agenix-new-generation" = {
    script = newGeneration;

    description =
      "A hacky way to ensure agenix decrypts files in a microvm setting.";

    before = [ "agenix-decrypt.service" ];
    wantedBy = [ "agenix-decrypt.service" ];

    serviceConfig.Type = "oneshot";
  };

  systemd.services."agenix-decrypt" = {
    script = installSecrets;

    description =
      "A hacky way to ensure agenix decrypts files in a microvm setting.";

    before = [ "tailscale-autoconnect.service" ];
    wantedBy = [ "tailscale-autoconnect.service" ];

    serviceConfig.Type = "oneshot";
  };

  systemd.services.tailscale.after = if config.services.tailscale.enable then
    [ "agenix-decrypt.service" ]
  else
    [ ];
}
