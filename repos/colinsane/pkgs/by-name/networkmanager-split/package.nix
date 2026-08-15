{
  deepLinkIntoOwnPackage,
  fetchpatch,
  networkmanager,
}:
let
  networkmanager' = networkmanager.overrideAttrs (base: {
    # src = fetchFromGitea {
    #   domain = "git.uninsane.org";
    #   owner = "colin";
    #   repo = "NetworkManager";
    #   # patched to fix polkit permissions (with `nmcli`) when NetworkManager runs as user networkmanager
    #   rev = "dev-sane-1.48.0";
    #   hash = "sha256-vGmOKtwVItxjYioZJlb1og3K6u9s4rcmDnjAPLBC3ao=";
    # };

    patches = (base.patches or []) ++ [
      (fetchpatch {
        # this one is relevant only to the daemon:
        name = "polkit: add owner annotations to all actions";
        url = "https://git.uninsane.org/colin/NetworkManager/commit/4bcba9cf97b9cccf16c2bba4002f770bc0a6afca.diff";
        hash = "sha256-U4DhAsuqbX0CtsmZaAwb+FJKd1hfgFMqTAdNUTpnVeo=";
      })
      (fetchpatch {
        # this one is relevant only to nmcli/nmtui (where it fixes a hang)
        name = "nm-secret-agent-old: allow dbus requests from 'networkmanager' user";
        url = "https://git.uninsane.org/colin/NetworkManager/commit/13d6c0449863a25cf908a08497bdf03a1f48d0cf.diff";
        hash = "sha256-+8kPU/0dNdXQ8feP4Jl1cJ4IaCUbVkBy6KHrn3kB6C4=";
      })
    ];
  });
in
(deepLinkIntoOwnPackage networkmanager' { outputs = [ "doc" "man" "out" ]; }).overrideAttrs (base: {
  outputs = [ "out" "daemon" "nmcli" ];

  postFixup = ''
    # assume all outputs (until mentioned later) are associated with the daemon:
    moveToOutput "" "$daemon"

    # move select outputs to `nmcli`:
    for f in \
      bin/{nmcli,nmtui,nmtui-connect,nmtui-edit,nmtui-hostname} \
      share/bash-completion/completions/nmcli \
      share/man/man1/{nmcli,nmtui,nmtui-connect,nmtui-edit,nmtui-hostname}.1.gz \
    ; do
      moveToOutput "$f" "$nmcli"
    done

    # ensure non-empty default output so the build doesn't fail
    mkdir "$out"
  '';

  meta = base.meta // {
    outputsToInstall = [ ];
  };

  passthru = {
    networkmanager = networkmanager';
  };
})
