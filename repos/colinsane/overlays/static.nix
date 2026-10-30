# this file contains build fixes or runtime fixes specific to statically-linked packages.
# for failure modes which reproduce outside of the `pkgsStatic` set, refer to overlays/patches.nix instead.
# e.g.
# - `pkgsStatic.x` fails, but `pkgsMusl.x` builds (or fails in a different manner): fix belongs here.
# - `pkgsStatic.x` fails, and `pkgsMusl.x` fails in a similar manner: see overlays/patches.nix.
final: prev:
let
  inherit (final.stdenv.hostPlatform) hasSharedLibraries;
in
{
  # nixpkgs' gobject-introspection has all `isStatic` platforms as badPlatforms,
  # but hopefully it's just `hasSharedLibraries == false` that's broken (untested)
  # gobject-introspection = prev.gobject-introspection.overrideAttrs (upstream: {
  #   meta = upstream.meta // {
  #     badPlatforms = [];
  #   };
  # });

  # gobject-introspection = if hasSharedLibraries then prev.gobject-introspection else null;

  libglvnd = prev.libglvnd.overrideAttrs (upstream: {
    meta = upstream.meta // {
      # mark as not bad, to unblock an assertion in SDL3.
      #
      # glvnd claims static linking isn't supported, but i think they're actually
      # talking about the case of `dlopen` not being available. there's a different stdenv attr to check for that.
      # <https://gitlab.freedesktop.org/glvnd/libglvnd/-/issues/212>
      badPlatforms = [];
    };
  });

  python3Minimal = prev.python3Minimal.overrideAttrs (upstream: {
    # Static linking exposes duplicate _mi_heap_{main,empty} symbols between
    # CPython's bundled mimalloc (3.13+) and our mimalloc-backed musl.
    configureFlags = upstream.configureFlags ++ final.lib.optionals (
      final.stdenv.hostPlatform.isMusl
      && (final.musl.allocatorModel or "malloc-ng") == "mimalloc"
      && final.lib.versionAtLeast upstream.version "3.13"
    ) [ "--without-mimalloc" ];

    # The static stdenv propagates build inputs, selecting bash's dev output.
    # Python needs the shell, not its headers.
    postFixup = (upstream.postFixup or "") + ''
      substituteInPlace "$out/nix-support/propagated-build-inputs" \
        --replace-fail '${final.lib.getDev final.bashNonInteractive}' '${final.lib.getBin final.bashNonInteractive}'
    '';

    # --disable-test-modules also omits the test directories on Python 3.14+.
    # With nullglob enabled, their cleanup otherwise runs `rm -R` with no args.
    postInstall = final.lib.replaceStrings
      [ "rm -R $out/lib/python*/test $out/lib/python*/**/test{,s}" ]
      [ "rm -Rf $out/lib/python*/test $out/lib/python*/**/test{,s}" ]
      upstream.postInstall;
  });

  # networkmanager = prev.networkmanager.override {
  #   gobject-introspection = if hasSharedLibraries then gobject-introspection else null;
  # };

  # sdl3 = prev.sdl3.override {
  #   # ibusMinimal -> gobject-introspection -> doesn't eval.
  #   # TODO: upstream this fix, or a patch that build ibus w/o introspection.
  #   ibusSupport = !hasSharedLibraries;
  # };
}
