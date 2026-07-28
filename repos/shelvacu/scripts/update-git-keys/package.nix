{
  lib,
  makeVacuPythonScript,
  vacuWrappedSops,
  vacuRoot,
  vacuPlainConfig,
}:
makeVacuPythonScript {
  name = "update-git-keys2";
  src = ./script.py;
  libraries = [ "requests" ];
  data = {
    sops_bin = lib.getExe vacuWrappedSops;
    git_keys_json = /${vacuRoot}/secrets/misc/git-keys.json;
    current_keys = vacuPlainConfig.vacu.ssh.authorizedKeys;
  };
}
