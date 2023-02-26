{callPackage, ...}: let
  buildFirefoxXpiAddon = callPackage ./builder.nix {};
in
  buildFirefoxXpiAddon {
    pname = "streetpass-for-mastodon";
    version = "2023.5";
    addonId = "streetpass@streetpass.social";
    url = "https://addons.mozilla.org/firefox/downloads/file/4064972/streetpass_for_mastodon-2023.5.xpi";
    sha256 = "sha256:196f842de4fa10865a5624c0f8d68d17997f105f82eed79909f2fa632731a212";
  }
