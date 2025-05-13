{
  addon-version-lister,
  genericUpdater,
  lib,
  writeShellScript,
}:
genericUpdater {
  versionLister = writeShellScript "version-lister" ''
    VERSION_LISTER_URL=$(nix-instantiate --eval . -A "''${UPDATE_NIX_ATTR_PATH}.src.url")
    ${lib.getExe addon-version-lister} --verbose --old-version "$UPDATE_NIX_OLD_VERSION" "$VERSION_LISTER_URL"
  '';
  ignoredVersions = "(b|rc)[0-9]*$";
}
