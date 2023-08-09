(
  final: prev: {
    xarchiver  = prev.xarchiver.overrideAttrs (o: {
      postInstall = ''
        rm -rf $out/libexec
      '';
    });

    xfce = prev.xfce.overrideScope (xfinal: xprev:  let

      thunar-wrapped = xprev.thunar-bare.override { thunarPlugins = [ { name = "none"; } ]; };

    in {
      thunar-archive-plugin = xprev.thunar-archive-plugin.overrideAttrs (old: {
        postInstall = ''
          cp -s  ${prev.xarchiver}/libexec/thunar-archive-plugin/* $out/libexec/thunar-archive-plugin/
        '';
      });
      
      thunar-full = thunar-wrapped.overrideAttrs (_: {
        paths = with xfinal; [
          thunar-bare
          thunar-archive-plugin
          thunar-media-tags-plugin
          tumbler
        ];
      });

      thunar-bare = xprev.thunar-bare.overrideAttrs (o: {
        postPatch = o.postPatch + ''
          sed -i -e 's|<command>.*</command>|<command>xdg-terminal-exec $SHELL -c "cd %f; $SHELL"</command>|' plugins/thunar-uca/uca.xml.in
        '';
      });
    });
  }
)
