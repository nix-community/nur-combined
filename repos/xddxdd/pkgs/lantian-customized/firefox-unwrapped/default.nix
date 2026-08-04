{
  buildMozillaMach,
  lib,
  stdenv,
  fetchurl,
  inputs,
  python3,
  wrapFirefox,
}:
let
  windowsFonts = inputs.chinese-fonts-overlay.packages.${stdenv.hostPlatform.system}.windows-fonts;
  pythonWithFontTools = python3.withPackages (p: [ p.fonttools ]);

  package =
    (buildMozillaMach {
      pname = "invisible-firefox";
      version = "153.0esr";
      src = fetchurl {
        url = "mirror://mozilla/firefox/releases/153.0esr/source/firefox-153.0esr.source.tar.xz";
        hash = "sha256-2+PZ3tyxGKS2I2iMVZxvLeKA6jvhceP/JWUEzAFibLU=";
      };

      meta = {
        maintainers = with lib.maintainers; [ xddxdd ];
        description = "Firefox with anti fingerprinting modifications";
        platforms = lib.platforms.unix;
        broken = stdenv.buildPlatform.is32bit;
        maxSilent = 21600; # 6h for PGO build (c.f. #129212, #129115)
        license = lib.licenses.mpl20;
        mainProgram = "firefox";
      };
    }).overrideAttrs
      (old: {
        patches = (old.patches or [ ]) ++ [
          ./0001-juggler.patch
          ./0002-browser.patch
          ./0003-docshell.patch
          ./0004-dom.patch
          ./0005-gfx-fonts.patch
          ./0006-js.patch
          ./0007-layout.patch
          ./0008-modules.patch
          ./0009-netwerk.patch
          ./0010-build-system.patch
          ./0011-toolkit.patch
          ./0012-uriloader.patch
          ./0013-widget.patch
          ./0014-xpcom.patch
          ./0015-devtools.patch
        ];

        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pythonWithFontTools ];

        postPatch = (old.postPatch or "") + ''
          # Stealthfox bundled-font persona: ship the Windows core font set from the
          # chinese-fonts-overlay windows-fonts package so the whitelisted families
          # render with genuine glyphs on every host (incl. Linux / macOS).
          find ${windowsFonts}/share/fonts/truetype/microsoft/ -maxdepth 1 \
            \( -name '*.ttf' -o -name '*.ttc' \) -exec cp -f {} browser/fonts/ \;
          # Regenerate the uniform-font-list manifest for the actual bundled files.
          mkdir -p scripts
          cp ${./gen_bundle_font_manifest.py} scripts/gen_bundle_font_manifest.py
          ${pythonWithFontTools}/bin/python3 scripts/gen_bundle_font_manifest.py
          # Inject the real bundled font filenames into the moz.build placeholder.
          # mozbuild requires FINAL_TARGET_FILES lists to be sorted by lowercased
          # filename (sorted(..., key=str.lower)); use python to produce exactly
          # that order, and include bundle-fonts.list in its sorted position.
          stealthFonts=$(
            cd browser/fonts &&
            ${pythonWithFontTools}/bin/python3 -c 'import glob;fs=sorted(glob.glob("*.ttf")+glob.glob("*.ttc")+["bundle-fonts.list"],key=str.lower);print(",".join(chr(34)+f+chr(34) for f in fs),end="")'
          )
          if [ -z "$stealthFonts" ]; then
            echo "error: no bundled fonts found in browser/fonts/" >&2
            exit 1
          fi
          substituteInPlace browser/fonts/moz.build \
            --replace-fail '"@@STEALTHFONTS@@"' "$stealthFonts"
        '';
      });
in
package
// {
  wrapped = wrapFirefox package { };
}
