(self: super:
with self;
let
  # ccache-able = drv: drv.override { stdenv = builtins.trace "with ccache ${drv.name}" ccacheStdenv; };
  ccache-able = drv: drv.override { stdenv = builtins.trace "with ccache: ${drv.name}" ccacheStdenv; };
in {
  # TODO: if we link /homeless-shelter/.ccache into the nix environment,
  # then maybe we get better use of upstream caches?
  # ccacheWrapper = super.ccacheWrapper.override {
  #   extraConfig = ''
  #     export CCACHE_DIR="/var/cache/ccache"
  #   '';
  # };
  # ccacheStdenv = super.ccacheStdenv.override {
  #   extraConfig = ''
  #     export CCACHE_DIR="/homeless-shelter/.ccache"
  #   '';
  # };
  # firefox-esr = ccache-able super.firefox-esr;
  # firefox/librewolf distribution is wacky: it grabs the stdenv off of `rustc.llvmPackages`, and really wants those to match.
  # buildMozillaMach = opts: ccache-able (super.buildMozillaMach opts);
  # webkitgtk = ccache-able super.webkitgtk;
  # mesa = ccache-able super.mesa;

  webkitgtk = super.webkitgtk.overrideAttrs (_upstream: {
    # means we drop debug info when linking.
    # this is a trade-off to require less memory when linking, since
    # building `webkitgtk` otherwise requires about 40G+ of RAM.
    # <https://github.com/NixOS/nixpkgs/issues/153528>
    separateDebugInfo = false;
  });
})
