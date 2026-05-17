{
  lib,
  applyPatches,
  fetchFromGitHub,
  fetchurl,
  haskell,
  haskellPackages,
  makeBinaryWrapper,
  wrapGAppsHook3,
  gsettings-desktop-schemas,
  gtk3,
  gdk-pixbuf,
  gst_all_1,
  ffmpeg,
  imagemagick,
}:

let
  version = "6.0.1.0";
  src = applyPatches {
    src = fetchFromGitHub {
      owner = "lettier";
      repo = "gifcurry";
      rev = "refs/tags/${version}";
      hash = "sha256-3xYGWIXLXxsjTgpEGObYG7z+WGFL2W+vUkGcBaGEEUE=";
    };
    patches = [
      (fetchurl {
        url = "https://github.com/nicholasmullikin/gifcurry/commit/621326558911f21cdb6fee6c787c17845d2d3a89.patch";
        hash = "sha256-NkaSEwSKcBKPoWGmsVUIKJS3RPDKpk0X7z7iaHo8RLE=";
      })
      ./gifcurry-gtk3-deps.patch
      ./gifcurry-data-text-qualify.patch
      ./gifcurry-gui-misc-text-qualify.patch
      ./gifcurry-gui-main-text-qualify.patch
      ./gifcurry-use-magick.patch
    ];
  };

  gstPluginsGood = gst_all_1.gst-plugins-good.override {
    gtkSupport = true;
  };

  package = haskellPackages.callPackage (
    {
      mkDerivation,
      aeson,
      base,
      bytestring,
      cairo,
      cmdargs,
      directory,
      filemanip,
      filepath,
      gi-cairo,
      gi-gdk3,
      gi-gdkpixbuf,
      gi-gio,
      gi-glib,
      gi-gobject,
      gi-gst,
      gi-gstbase,
      gi-gstvideo,
      gi-gtk3,
      gi-pango,
      haskell-gi,
      haskell-gi-base,
      pango,
      process,
      pureMD5,
      system-fileio,
      system-filepath,
      temporary,
      text,
      time,
      transformers,
      yaml,
    }:
    mkDerivation {
      pname = "Gifcurry";
      inherit src version;
      isLibrary = true;
      isExecutable = true;
      enableSeparateDataOutput = true;

      libraryHaskellDepends = [
        base
        bytestring
        directory
        filemanip
        filepath
        process
        temporary
        text
        yaml
      ];

      executableHaskellDepends = [
        aeson
        base
        bytestring
        cairo
        cmdargs
        directory
        filemanip
        filepath
        gi-cairo
        gi-gdk3
        gi-gdkpixbuf
        gi-gio
        gi-glib
        gi-gobject
        gi-gst
        gi-gstbase
        gi-gstvideo
        gi-gtk3
        gi-pango
        haskell-gi
        haskell-gi-base
        pango
        process
        pureMD5
        system-fileio
        system-filepath
        temporary
        text
        time
        transformers
        yaml
      ];
    }
  ) { };
in
haskell.lib.doJailbreak (
  package.overrideAttrs (old: {
    inherit src version;

    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      makeBinaryWrapper
      wrapGAppsHook3
    ];
    buildInputs = (old.buildInputs or [ ]) ++ [
      gtk3
      gdk-pixbuf
      gsettings-desktop-schemas
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gstPluginsGood
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-libav
    ];

    gappsWrapperArgs = (old.gappsWrapperArgs or [ ]) ++ [
      "--prefix"
      "PATH"
      ":"
      "${lib.makeBinPath [
        ffmpeg
        imagemagick
        gst_all_1.gstreamer
      ]}"
    ];

    postFixup = (old.postFixup or "") + ''
      gstPluginPath="${
        lib.makeSearchPath "lib/gstreamer-1.0" [
          gst_all_1.gst-plugins-base
          gstPluginsGood
          gst_all_1.gst-plugins-bad
          gst_all_1.gst-plugins-ugly
          gst_all_1.gst-libav
        ]
      }"
      for exe in $out/bin/gifcurry_gui $out/bin/gifcurry_cli; do
        if [ -e "$exe" ]; then
          wrapProgram "$exe" --prefix PATH : "${
            lib.makeBinPath [
              ffmpeg
              imagemagick
              gst_all_1.gstreamer
            ]
          }" \
          --prefix GST_PLUGIN_PATH : "$gstPluginPath" \
          --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$gstPluginPath"
        fi
      done
    '';

    postInstall = (old.postInstall or "") + ''
      install -Dm644 packaging/linux/common/com.lettier.gifcurry.desktop \
        $out/share/applications/com.lettier.gifcurry.desktop
      install -Dm644 packaging/linux/common/com.lettier.gifcurry.svg \
        $out/share/icons/hicolor/scalable/apps/com.lettier.gifcurry.svg
      install -Dm644 packaging/linux/common/com.lettier.gifcurry.appdata.xml \
        $out/share/metainfo/com.lettier.gifcurry.appdata.xml
    '';

    meta = with lib; {
      description = "Haskell-built video editor for GIF makers (GUI and CLI)";
      homepage = "https://github.com/lettier/gifcurry";
      license = licenses.bsd3;
      mainProgram = "gifcurry_gui";
      platforms = platforms.linux ++ platforms.darwin;
    };
  })
)
