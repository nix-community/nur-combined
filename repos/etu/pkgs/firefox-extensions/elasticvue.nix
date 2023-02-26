{callPackage, ...}: let
  buildFirefoxXpiAddon = callPackage ./builder.nix {};
in
  buildFirefoxXpiAddon {
    pname = "elasticvue";
    version = "0.44.0";
    addonId = "{2879bc11-6e9e-4d73-82c9-1ed8b78df296}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4036001/elasticvue-0.44.0.xpi";
    sha256 = "sha256:2805fb9b89669f30a644aa555fd6090300792668df38cd33540e65ccc5249c6d";
  }
