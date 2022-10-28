{
  applyPatches,
  fetchgit,
  writeScript,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  (applyPatches {
    patches = [./build.patch];
    src = fetchgit {
      inherit (source) url rev sha256 fetchLFS fetchSubmodules deepClone leaveDotGit;
    };
  })
  .overrideAttrs (_: {
    passthru.source = source;
    passthru.updateScript = writeScript "update-paper-git" ''
      ${../../scripts/update-git.sh} https://github.com/PaperMC/Paper minecraft/papermc/source.json "--leave-dotGit --fetch-submodules"
    '';
  })
