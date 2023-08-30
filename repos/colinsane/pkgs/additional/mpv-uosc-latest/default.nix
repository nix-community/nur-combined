{ lib
, fetchFromGitHub
, fetchFromGitea
, mpvScripts
}:
mpvScripts.uosc.overrideAttrs (upstream: {
  version = "unstable-2023-08-29";
  # src = fetchFromGitHub {
  #   owner = "tomasklaen";
  #   repo = "uosc";
  #   rev = "e783ad1f133e06a50d424291143d25497fbecfdd";
  #   hash = "sha256-FFl51Kv5eMNyB4LM4JmjJXDnd/XvvtXZbHsRpSkSGqE=";
  # };
  src = lib.warnIf (upstream.version != "4.7.0") "mpv-uosc-latest is behind nixpkgs mpvScripts.uosc ${upstream.version}" fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "uosc";
    rev = "sane-0.2";
    hash = "sha256-j5hX+lAf7mHx4vqI0shOekmOh4aZsOiRb3rPs8vQ4qo=";
    # for version > 4.7.0, we can use nixpkgs src and set `patches` to a fetch of my one custom commit
  };
  passthru = upstream.passthru // {
    scriptName = "uosc";
  };
  postPatch = "";  # delete the outdated `path` fix
})
