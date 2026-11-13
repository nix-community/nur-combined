{
  lib,
  pkgs,
  vacuModuleType,
  ...
}:
let
  bitwarden = pkgs.bitwarden-extension;
  firefox = pkgs.firefox-unwrapped.override (
    if pkgs.firefox-unwrapped ? enableAddonSigning then
      {
        enableAddonSigning = false;
        enablePGO = false;
      }
    else
      {
        requireSigning = false;
        pgoSupport = false;
      }
  );
in
lib.optionalAttrs (vacuModuleType == "nixos") {
  programs.firefox = {
    package = pkgs.wrapFirefox firefox { };
    policies.ExtensionSettings.${bitwarden.extid} = {
      installation_mode = "force_installed";
      install_url = "file://${bitwarden}/${bitwarden.extid}.xpi";
      updates_disabled = true;
    };
    preferences."xpinstall.signatures.required" = false;
  };
}
