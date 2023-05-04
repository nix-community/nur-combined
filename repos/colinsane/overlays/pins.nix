# when a `nixos-rebuild` fails after a nixpkgs update:
# - take the failed package
# - search it here: <https://hydra.nixos.org/search?query=pkgname>
# - if it's broken by that upstream builder, then pin it: somebody will come along and fix the package.
# - otherwise, search github issues/PRs for knowledge of it before pinning.
# - if nobody's said anything about it yet, probably want to root cause it or hold off on updating.
#
# note that these pins apply to *all* platforms:
# - natively compiled packages
# - cross compiled packages
# - qemu-emulated packages

(next: prev: {
  # XXX: when invoked outside our flake (e.g. via NIX_PATH) there is no `next.stable`,
  # so just forward the unstable packages.
  inherit (next.stable or prev)
  ;
  # chromium can take 4 hours to build from source, with no signs of progress.
  # disable it if you're in a rush.
  # chromium = next.emptyDirectory;

  # lemmy-server = prev.lemmy-server.overrideAttrs (upstream: {
  #   patches = upstream.patches or [] ++ [
  #     (next.fetchpatch {
  #       # "Fix docker federation setup (#2706)"
  #       url = "https://github.com/LemmyNet/lemmy/commit/2891856b486ad9397bca1c9839255d73be66361.diff";
  #       hash = "sha256-qgRvBO2y7pmOWdteu4uiZNi8hs0VazOV+L5Z0wu60/E=";
  #     })
  #   ];
  # });
})
