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
        url = "https://git.uninsane.org/colin/NetworkManager/commit/a01293861fa24201ffaeb84c07f1c71136c49759.patch";
        hash = "sha256-th1/M2slo7rjkVBwETZII53Lmhyw8OMS0aT9QYI5Uvk=";
      })
      (fetchpatch {
        # this one is relevant only to nmcli/nmtui (where it fixes a hang)
        name = "nm-secret-agent-old: allow dbus requests from 'networkmanager' user";
        url = "https://git.uninsane.org/colin/NetworkManager/commit/31c88239a067bbf8d6c638c6f8247547fddd4885.patch";
        hash = "sha256-+8kPU/0dNdXQ8feP4Jl1cJ4IaCUbVkBy6KHrn3kB6C4=";
      })
    ];
  });
in
(deepLinkIntoOwnPackage networkmanager').overrideAttrs (base: {
  outputs = [ "out" "daemon" "nmcli" ];

  postFixup = ''
    moveToOutput "" "$daemon"
    for f in bin/{nmcli,nmtui,nmtui-connect,nmtui-edit,nmtui-hostname} share/bash-completion/completions/nmcli; do
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
