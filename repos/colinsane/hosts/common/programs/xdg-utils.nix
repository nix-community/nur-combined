{ ... }:
{
  sane.programs.xdg-utils = {
    # xdg-open may need to open things with elevated perms, like wireshark.
    # generally, the caller can be trusted to sandbox it.
    # if the caller is sandboxed, it will typically set NIXOS_XDG_OPEN_USE_PORTAL=1,
    # and then xdg-open simply forwards the request to dbus `org.freedesktop.portal.OpenURI` (i.e. xdg-desktop-portal).
    #
    # N.B.: `xdg-desktop-portal` seems to (inadvertently) only accept requests from applications which *don't* have elevated privileges.
    # this will be true of nearly all sandboxed applications, but for those which it is not, `sandbox.method = "capshonly"` may be necessary
    sandbox.enable = false;

    # `mimetype` provides better mime associations than `file`
    # - see: <https://github.com/NixOS/nixpkgs/pull/285233#issuecomment-1940828629>
    suggestedPrograms = [
      # "perlPackages.FileMimeInfo"
      "mimetype"
      # "mimeopen"  #< optional, unclear what benefit
    ];

    # alternative to letting the sandbox decide for itself: forcibly use the portal
    #   if the mime association list is not visible/in scope.
    # packageUnwrapped = pkgs.xdg-utils.overrideAttrs (base: {
    #   postInstall = base.postInstall + ''
    #     sed '2i\
    #     if ! [ -e ~/.local/share/applications ]; then\
    #       NIXOS_XDG_OPEN_USE_PORTAL=1\
    #     fi\
    #     ' -i "$out"/bin/*
    #   '';
    # });
  };
}
