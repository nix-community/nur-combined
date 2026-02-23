{
  writeShellScriptBin,
  callPackage,
  lib,
}:
let
  git-sops = callPackage ../git-sops/package.nix { };
in
writeShellScriptBin "setup-git-sops" ''
  git config filter.git-sops.clean "${lib.getExe git-sops} clean %f"
  git config filter.git-sops.smudge "${lib.getExe git-sops} smudge %f"
  git config filter.git-sops.required true
  git config diff.git-sops.textconv cat
''
// {
  meta = {
    description = "Setup git repository with filter and diff for sops auto encryption";
    homepage = "https://github.com/ToyVo/nixcfg";
    license = lib.licenses.mit;
    mainProgram = "setup-git-sops";
  };
}
