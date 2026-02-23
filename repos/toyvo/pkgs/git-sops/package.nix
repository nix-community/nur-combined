{ writeShellScriptBin, lib }:
writeShellScriptBin "git-sops" (builtins.readFile ./git-sops.bash)
// {
  meta = {
    description = "Git filter driver for transparent sops encryption and decryption";
    homepage = "https://github.com/ToyVo/nixcfg";
    license = lib.licenses.mit;
    mainProgram = "git-sops";
  };
}
