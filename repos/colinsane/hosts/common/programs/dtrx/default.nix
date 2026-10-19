{ lib, pkgs, ... }:
{
  sane.programs.dtrx = {
    packageUnwrapped = pkgs.dtrx.overridePythonAttrs (prevAttrs: {
      src = lib.warnIf (lib.versionOlder "8.7.1" prevAttrs.version) "new dtrx release: drop override?" prevAttrs.src.overrideAttrs {
        # 2026-09-27: includes my fix to support .a archive formats
        # <https://github.com/dtrx-py/dtrx/pull/73>
        rev = "e2ba967eec65ec9e1c2892efc2f5116b61d4a5fe";
        hash = "sha256-EXaiQqdPw39z43luMkJmm6GbpyERGsOZFx7WoNHyawU=";
      };
    });
    sandbox.whitelistPwd = true;
    sandbox.autodetectCliPaths = "existing";  #< for the archive
  };
}
