# Shared builder for Mozilla add-on XPI files published by addons.mozilla.org.
#
# The XPI is installed unmodified, so the Mozilla signature on it stays valid.
# Two layouts are produced because they are consumed by different interfaces:
#
#   - $out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/<addonId>.xpi
#     Used by Home Manager's `programs.firefox.profiles.<name>.extensions.packages`
#     (and by the older `programs.firefox.globalExtensions`), and by
#     `ExtensionSettings.<id>.install_url` in `programs.firefox.policies`.
#
#   - $out/<addonId>.xpi
#     Used by nixpkgs' `wrapFirefox` through the `nixExtensions` argument, which
#     requires the `extid` passthru attribute.
#
# The upstream implementation of this builder lives in
# <https://gitlab.com/rycee/nur-expressions> (MIT licensed).
{ lib }:

{
  mkBuildMozillaXpiAddon =
    { stdenv, fetchurl }:
    lib.makeOverridable (
      { pname, version, addonId, url, sha256, meta ? { }, ... }:
      stdenv.mkDerivation {
        name = "${pname}-${version}";
        inherit meta;

        src = fetchurl {
          inherit url sha256;
        };

        dontUnpack = true;
        strictDeps = true;

        installPhase = ''
          runHook preInstall

          policyDir="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
          mkdir -p "$policyDir"
          install -v -m 644 "$src" "$policyDir/${addonId}.xpi"

          # Layout expected by nixpkgs' `nixExtensions` support.
          install -v -m 644 "$src" "$out/${addonId}.xpi"

          runHook postInstall
        '';

        passthru = {
          inherit addonId;
          extid = addonId;
        };

        # Additions are tiny and fully substitutable, so let the CI cache them.
        preferLocalBuild = false;
      }
    );
}
