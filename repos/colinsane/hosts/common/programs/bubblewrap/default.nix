{ pkgs, ... }:
{
  sane.programs.bubblewrap = {
    sandbox.enable = false;  # don't sandbox the sandboxer :)
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
        #
        # note that invoking bwrap with capabilities in the 'init' namespace does NOT grant the sandboxed process
        # capabilities in the 'init' namespace. it's a limitation of namespaces that namespaced processes can
        # never receive capabilities in their parent namespace.
        substituteInPlace bubblewrap.c --replace-fail \
          'die ("Unexpected capabilities but not setuid, old file caps config?");' \
          '// die ("Unexpected capabilities but not setuid, old file caps config?");'

        # enable debug printing
        # substituteInPlace utils.h --replace-fail \
        #   '#define __debug__(x)' \
        #   '#define __debug__(x) printf x'
      '';
    });
  };
}
