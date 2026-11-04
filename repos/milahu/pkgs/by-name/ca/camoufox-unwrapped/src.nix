# based on https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/li/librewolf-unwrapped/src.nix

{
  lib,
  fetchurl,
  fetchFromGitHub,
}:

rec {
  firefoxVersion = "158.0.1";

  # TODO rename?
  camoufoxVersion = "beta.41";

  # TODO? rename to fullVersion
  version = "${firefoxVersion}-${camoufoxVersion}";

  firefoxSource = fetchurl {
    url = "https://archive.mozilla.org/pub/firefox/releases/${firefoxVersion}/source/firefox-${firefoxVersion}.source.tar.xz";
    hash = "sha256-tb7/VfpzoppnSoZ9pZIvXXaZ9R41Hmu+RAX8xLpVqCQ=";
  };

  camoufoxSource = fetchFromGitHub {
    owner = "daijro";
    repo = "camoufox";
    tag = "v${version}";
    hash = "sha256-w5c8KvHSPMCyHG+V9m169Q5RCt/enDsJof+VnXpqmoU=";
  };
}
