{ pkgs, ... }:
pkgs.telegram-desktop.overrideAttrs (
  finalAttrs: previousAttrs: 
  with pkgs;
  let
    mainProgram = if stdenv.isLinux then "ayugram-desktop" else "Ayugram";
  in
  {
    pname = "ayugram-desktop";
    version = "5.2.2";

    src = fetchFromGitHub {
      owner = "AyuGram";
      repo = "AyuGramDesktop";
      rev = "v${finalAttrs.version}";
      fetchSubmodules = true;
      hash = "sha256-XaywX/kxRxN7vkItsvNGexjoukfAyyvEVMrn1Vy7U54=";
    };

    installPhase = lib.optionalString stdenv.isDarwin ''
      mkdir -p $out/Applications
      cp -r ${mainProgram}.app $out/Applications
      ln -s $out/{Applications/${mainProgram}.app/Contents/MacOS,bin}
    '';

    patches = builtins.filter (p: !builtins.isAttrs p || p.name == "Disable-register-custom-scheme") previousAttrs.patches;

    # Since the original .desktop file is for Flatpak, we need to fix it.
    postInstall =
      lib.optionalString stdenv.isLinux
        # Rudiment: related functionality is disabled by disabling the auto-updater
        # and it breaks the .desktop file in Aylur's Gtk Shell
        # (with it, it causes the application to not be seen by the app launcher).
        # https://github.com/AyuGram/AyuGramDesktop/blob/5566a8ca0abe448a7f1865222b64b68ed735ee07/Telegram/SourceFiles/platform/linux/specific_linux.cpp#L455
        ''
          substituteInPlace $out/share/applications/com.ayugram.desktop.desktop \
            --replace-fail 'Exec=DESKTOPINTEGRATION=1 ' 'Exec='
        ''
      +
        # Since we aren't in Flatpak, "DBusActivatable" has no unit to
        # activate and it causes the .desktop file to show the error "Could not activate remote peer
        # 'com.ayugram.desktop': unit failed" (at least on KDE6).
        ''
          substituteInPlace $out/share/applications/com.ayugram.desktop.desktop \
            --replace-fail 'DBusActivatable=true' '# DBusActivatable=true'
        '';

    postFixup =
      lib.optionalString stdenv.isLinux ''
        # This is necessary to run Telegram in a pure environment.
        # We also use gappsWrapperArgs from wrapGAppsHook.
        wrapProgram $out/bin/${mainProgram} \
          "''${gappsWrapperArgs[@]}" \
          "''${qtWrapperArgs[@]}" \
          --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}
      ''
      + lib.optionalString stdenv.isDarwin ''
        wrapQtApp $out/Applications/${mainProgram}.app/Contents/MacOS/${mainProgram}
      '';

    meta = (builtins.removeAttrs previousAttrs.meta [ "longDescription" ]) // {
      description = "Desktop Telegram client with good customization and Ghost mode";
      homepage = "https://github.com/AyuGram/AyuGramDesktop";
      changelog = "https://github.com/AyuGram/AyuGramDesktop/blob/v${finalAttrs.version}/changelog.txt";
      maintainers = [ ];
      inherit mainProgram;
    };
  }
)
