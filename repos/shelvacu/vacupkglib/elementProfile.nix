{ pkgs, lib, ... }: {
  # element-desktop can already run several accounts side by side (`--profile
  # <name>`, one ~/.config/Element-<name> per account), but every instance ends
  # up with the same window class and the same icon, so the panel can't tell
  # them apart. This wraps element-desktop for one profile, giving it its own
  # launcher, its own icon and its own window class.
  elementProfile =
    {
      profile,
      icon, # path to an svg (rasterised at build time) or a png
      label ? profile,
      element ? pkgs.element-desktop,
    }:
    let
      id = "element-desktop-${profile}";
      isSvg = lib.hasSuffix ".svg" (builtins.toString icon);
    in
    pkgs.runCommand id
      {
        nativeBuildInputs = [
          pkgs.makeWrapper
          pkgs.jq
          pkgs.asar
        ]
        ++ lib.optional isSvg pkgs.librsvg;
        meta = element.meta // {
          description = "element-desktop, as the '${profile}' profile";
          mainProgram = id;
        };
      }
      ''
        mkdir -p $out/bin $out/libexec $out/share/applications $out/share/${id}/build

        # Electron takes WM_CLASS (X11) and the app_id (wayland) from
        # $CHROME_DESKTOP, but overwrites that at startup with the app's own
        # `desktopName` -- falling back to the lowercased product name, i.e.
        # "element.desktop" for every instance. Setting it in the environment
        # (or passing --class) therefore does nothing; the value has to come
        # from the package.json inside app.asar.
        asar extract ${element}/share/element/app.asar unpacked
        jq --arg d "${id}.desktop" '. + { desktopName: $d }' \
          unpacked/package.json > package.json.new
        mv package.json.new unpacked/package.json
        asar pack unpacked $out/share/${id}/app.asar
        rm -rf unpacked
        # element finds these relative to the realpath of app.asar, so they
        # have to sit next to our copy rather than the original
        ln -s ${element}/share/element/webapp $out/share/${id}/webapp

        # $out/share/${id}/build/icon.png is the icon element loads itself:
        # _NET_WM_ICON on X11, and the tray icon. The copies under
        # share/icons/hicolor are what the panel resolves by name out of the
        # .desktop entry.
        ${
          if isSvg then
            ''
              install -Dm444 ${icon} $out/share/icons/hicolor/scalable/apps/${id}.svg
              rsvg-convert --width 512 --height 512 --keep-aspect-ratio \
                ${icon} --output $out/share/${id}/build/icon.png
            ''
          else
            ''
              install -Dm444 ${icon} $out/share/${id}/build/icon.png
            ''
        }
        install -Dm444 $out/share/${id}/build/icon.png \
          $out/share/icons/hicolor/512x512/apps/${id}.png

        # element's launcher has the asar path baked in; point it at ours
        substitute ${element}/bin/element-desktop $out/libexec/${id} \
          --replace-fail ${element}/share/element/app.asar $out/share/${id}/app.asar
        chmod +x $out/libexec/${id}

        makeWrapper $out/libexec/${id} $out/bin/${id} \
          --add-flags "--profile ${profile}"

        substitute ${element}/share/applications/element-desktop.desktop \
          $out/share/applications/${id}.desktop \
          --replace-fail 'Exec=element-desktop %u' "Exec=$out/bin/${id} %u" \
          --replace-fail 'Icon=element' 'Icon=${id}' \
          --replace-fail 'Name=Element' 'Name=Element (${label})' \
          --replace-fail 'StartupWMClass=Element' 'StartupWMClass=${id}'
        # leave the element:// scheme handler to the unprofiled install
        sed -i '/^MimeType=/d' $out/share/applications/${id}.desktop
      '';
}
