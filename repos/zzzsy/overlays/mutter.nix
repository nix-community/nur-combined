(final: prev: {
  gnome = prev.gnome.overrideScope (
    final': prev': {

      mutter = prev'.mutter.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [
          ./mutter-triple-buffering.patch
          ./mutter-text-input-v1.patch
        ];
      });
      gnome-shell = prev'.gnome-shell.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [ ./gnome-shell-preedit-fix.patch ];
      });
    }
  );
})
