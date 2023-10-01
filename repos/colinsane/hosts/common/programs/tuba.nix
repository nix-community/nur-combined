{ pkgs, ... }:
{
  sane.programs.tuba = {
    package = pkgs.tuba.overrideAttrs (upstream: {
      postInstall = (upstream.postInstall or "") + ''
        # ship a `tuba` alias to the actual tuba binary, since i can never remember its name
        ln -s $out/bin/dev.geopjr.Tuba $out/bin/tuba
      '';

      preFixup = (upstream.preFixup or "") + ''
        # 2023/09/24: fix so i can upload media when creating a post.
        # see: <https://github.com/GeopJr/Tuba/issues/414#issuecomment-1732695845>
        gappsWrapperArgs+=(
          --prefix GDK_DEBUG , no-portals
        )
      '';
      # alternative to disabling portals is to remove the filters on FileDialogs.
      # done like so (but would want to apply to the other dialogs too)
      # postPatch = (upstream.postPatch or "") + ''
      #   substituteInPlace src/Dialogs/ProfileEdit.vala \
      #     --replace "default_filter = filter" ""
      # '';
    });
    suggestedPrograms = [ "gnome-keyring" ];
  };
}
