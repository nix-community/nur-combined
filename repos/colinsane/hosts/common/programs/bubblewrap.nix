{ pkgs, ... }:
{
  sane.programs.bubblewrap = {
    packageUnwrapped = pkgs.bubblewrap.overrideAttrs (base: {
      # patches = (base.patches or []) ++ [
      #   (pkgs.fetchpatch {
      #     url = "https://git.uninsane.org/colin/bubblewrap/commit/9843f9b2b5f086563fd37250658d69350a2939be.patch";
      #     name = "enable debug logging and add a bunch more tracing";
      #     hash = "sha256-AlDsqddaBahhqGibZlCjgmChuK7mmxDt0aYHNgY05OI=";
      #   })
      # ];
      postPatch = (base.postPatch or "") + ''
        # bwrap doesn't like to be invoked with any capabilities, which is troublesome if i
        # want to do things like ship CAP_NET_ADMIN,CAP_NET_RAW in the ambient set for tools like Wireshark.
        # but this limitation of bwrap is artificial and at first look is just a scenario the author probably
        # never expected: patch out the guard check.
        #
        # see: <https://github.com/containers/bubblewrap/issues/397>
        substituteInPlace bubblewrap.c --replace \
          'die ("Unexpected capabilities but not setuid, old file caps config?");' \
          '// die ("Unexpected capabilities but not setuid, old file caps config?");'

        # bwrap bin/foo produces two processes:
        # - the parent (occupies the namespace from which it's called)
        # - the child (occupies new namespaces, created for it by the parent).
        # this patch changes the parent to not drop *all* privs, hoping that this would allow
        # privileged sandboxes to do privileged net operations.
        # but in actuality, processes within a child namespace can *NEVER* have capabilities within
        # their parent namespace.
        # substituteInPlace bubblewrap.c --replace \
        #   'drop_privs (FALSE, FALSE)' \
        #   'drop_privs (TRUE, FALSE)'

        # enable debug printing
        # substituteInPlace utils.h --replace \
        #   '#define __debug__(x)' \
        #   '#define __debug__(x) printf x'
      '';
    });
  };
}
