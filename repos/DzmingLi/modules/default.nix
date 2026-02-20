let
  hasSuffix =
    suffix: str:
    let
      suffixLen = builtins.stringLength suffix;
      strLen = builtins.stringLength str;
    in
    strLen >= suffixLen && builtins.substring (strLen - suffixLen) suffixLen str == suffix;

  removeSuffix =
    suffix: str:
    let
      suffixLen = builtins.stringLength suffix;
      strLen = builtins.stringLength str;
    in
    if hasSuffix suffix str then
      builtins.substring 0 (strLen - suffixLen) str
    else
      str;

  importModulesFromDir =
    dir:
    let
      entries = builtins.readDir dir;
      names = builtins.attrNames entries;
      isDefault = name: name == "default.nix";
      isDir = name: entries.${name} == "directory" && builtins.pathExists "${dir}/${name}/default.nix";
      isFile = name: entries.${name} == "regular" && hasSuffix ".nix" name && !isDefault name;
      dirMods = builtins.listToAttrs (map (name: {
        name = name;
        value = "${dir}/${name}";
      }) (builtins.filter isDir names));
      fileMods = builtins.listToAttrs (map (name: {
        name = removeSuffix ".nix" name;
        value = "${dir}/${name}";
      }) (builtins.filter isFile names));
    in
    dirMods // fileMods;

  legacyModules = importModulesFromDir ./.;
  nixosModules =
    if builtins.pathExists ./nixos then
      importModulesFromDir ./nixos
    else
      { };
  homeManagerModules =
    if builtins.pathExists ./home-manager then
      importModulesFromDir ./home-manager
    else
      { };
in
legacyModules
// {
  nixos = nixosModules;
  home-manager = homeManagerModules;
}
