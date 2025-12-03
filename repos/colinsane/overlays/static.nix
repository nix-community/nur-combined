final: prev:
with final;
let
  inherit (stdenv.hostPlatform) hasSharedLibraries;
in
{
  # glibcLocales is null on musl, but some packages still refer to it.
  # is this sensible? idk.
  glibcLocales = final.pkgsCross.gnu64.glibcLocales;

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

  # networkmanager = prev.networkmanager.override {
  #   gobject-introspection = if hasSharedLibraries then gobject-introspection else null;
  # };

  # sdl3 = prev.sdl3.override {
  #   # ibusMinimal -> gobject-introspection -> doesn't eval.
  #   # TODO: upstream this fix, or a patch that build ibus w/o introspection.
  #   ibusSupport = !hasSharedLibraries;
  # };
}
