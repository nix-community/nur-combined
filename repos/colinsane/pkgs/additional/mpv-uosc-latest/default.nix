{ mpvScripts
, fetchFromGitHub
, fetchFromGitea
}:
mpvScripts.uosc.overrideAttrs (upstream: {
  version = "unstable-2023-07-26";
  # src = fetchFromGitHub {
  #   owner = "tomasklaen";
  #   repo = "uosc";
  #   rev = "e783ad1f133e06a50d424291143d25497fbecfdd";
  #   hash = "sha256-FFl51Kv5eMNyB4LM4JmjJXDnd/XvvtXZbHsRpSkSGqE=";
  # };
  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "uosc";
    rev = "dev/sane";
    hash = "sha256-XOhryppod3zozYrPQlGBw298u+0/eS1MaDepV4p88cM=";
    # for version > 4.7.0, we can use nixpkgs src and set `patches` to a fetch of my one custom commit
  };
  passthru = upstream.passthru // {
    scriptName = "uosc";
  };
  postPatch = "";  # delete the outdated `path` fix
})
