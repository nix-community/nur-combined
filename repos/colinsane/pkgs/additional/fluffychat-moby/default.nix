{ symlinkJoin, fluffychat, makeWrapper }:

(symlinkJoin {
  name = "fluffychat-moby";
  paths = [ fluffychat ];
  buildInputs = [ makeWrapper ];

  # ordinary fluffychat on moby displays blank window;
  # > Failed to start Flutter renderer: Unable to create a GL context
  # this is temporarily solved by using software renderer
  # - see https://github.com/flutter/flutter/issues/106941
  postBuild = ''
    wrapProgram $out/bin/fluffychat \
      --set LIBGL_ALWAYS_SOFTWARE 1
    # fix up the .desktop file to invoke our wrapped fluffychat
    orig_desktop=$(readlink $out/share/applications/Fluffychat.desktop)
    unlink $out/share/applications/Fluffychat.desktop
    sed "s:Exec=.*:Exec=$out/bin/fluffychat:" $orig_desktop > $out/share/applications/Fluffychat.desktop
  '';
})
