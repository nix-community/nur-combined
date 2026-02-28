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

  # Use plain strings to avoid store-path context when probing for default.nix;
  # this keeps evaluation working even when the Nix daemon/store is unavailable.
  importModulesFromDir =
    dir:
    let
      dirStr = builtins.unsafeDiscardStringContext (toString dir);
      entries = builtins.readDir dirStr;
      names = builtins.attrNames entries;
      isDefault = name: name == "default.nix";
      hasDefault = name:
        let path = "${dirStr}/${name}/default.nix"; in
        builtins.pathExists path;
      isDir = name: entries.${name} == "directory" && hasDefault name;
      isFile = name: entries.${name} == "regular" && hasSuffix ".nix" name && !isDefault name;
      dirMods = builtins.listToAttrs (map (name: {
        name = name;
        value = builtins.toPath "${dirStr}/${name}";
      }) (builtins.filter isDir names));
      fileMods = builtins.listToAttrs (map (name: {
        name = removeSuffix ".nix" name;
        value = builtins.toPath "${dirStr}/${name}";
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
