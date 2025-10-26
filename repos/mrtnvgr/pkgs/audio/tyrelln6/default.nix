# Resource patching taken from https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=uhe-hive-vst, thanks!

{ stdenvNoCC, fetchurl, autoPatchelfHook, xxd, hexdump, glib, cairo, freetype, xorg, zlib, gtk3, xdg-user-dirs }:
stdenvNoCC.mkDerivation {
  name = "Tyrell N6";
  version = "3.0-beta16976";

  src = fetchurl {
    url = "https://dl.u-he.com/releases/TyrellN6_300_public_beta_16976_Linux.tar.xz";
    hash = "sha256-TXpOvRJNwvNB2fU7xYWwylCIBqzMMkab/hha6ZukyRY=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    xxd
    hexdump
  ];

  buildInputs = [
    glib
    cairo
    freetype
    xorg.xcbutilkeysyms
    xorg.xcbutil
    xorg.libxcb
    zlib
    gtk3
    xdg-user-dirs
  ];

  buildPhase = ''
    runHook preBuild

    pushd TyrellN6

    function patch_strings_in_file() {
      # Source (Johan Hedin): http://everydaywithlinux.blogspot.com/2012/11/patch-strings-in-binary-files-with-sed.html
      # Slight modification by Colin Wallace to force the pattern to capture the entire line
      # Usage: patch_strings_in_file <file> <pattern> <replacement>
      # replaces all occurances of <pattern> with <replacement> in <file>, padding
      # <replacement> with null characters to match the length
      # Unlike sed or patch, this works on binary files
      local FILE="$1"
      local PATTERN="$2"
      local REPLACEMENT="$3"

      # Find all unique strings in FILE that contain the pattern
      STRINGS=$(strings "''${FILE}" | grep "^''${PATTERN}$" | sort -u -r)

      if [ "''${STRINGS}" != "" ] ; then
          echo "File ''${FILE}' contains strings equal to ''${PATTERN}':"

          for OLD_STRING in ''${STRINGS} ; do
              # Create null terminated ASCII HEX representations of the strings
              OLD_STRING_HEX="$(echo -n ''${OLD_STRING} | xxd -g 0 -u -ps -c 256)00"
              NEW_STRING_HEX="$(echo -n ''${REPLACEMENT} | xxd -g 0 -u -ps -c 256)00"

              if [ ''${#NEW_STRING_HEX} -le ''${#OLD_STRING_HEX} ] ; then
                  # Pad the replacement string with null terminations so the
                  # length matches the original string
                  while [ ''${#NEW_STRING_HEX} -lt ''${#OLD_STRING_HEX} ] ; do
                      NEW_STRING_HEX="''${NEW_STRING_HEX}00"
                  done

                  # Now, replace every occurrence of OLD_STRING with NEW_STRING
                  echo -n "Replacing ''${OLD_STRING} with ''${REPLACEMENT}... "
                  hexdump -ve '1/1 "%.2X"' ''${FILE} | \
                  sed "s/''${OLD_STRING_HEX}/''${NEW_STRING_HEX}/g" | \
                  xxd -r -p > ''${FILE}.tmp
                  chmod --reference ''${FILE} ''${FILE}.tmp
                  mv ''${FILE}.tmp ''${FILE}
                  echo "Done!"
              else
                  echo "New string ''${NEW_STRING}' is longer than old" \
                       "string ''${OLD_STRING}'. Skipping."
              fi
          done
      fi
    }

  # The binaries use a scheme that causes paths to all be ~/.uhe/TyrellN6
  # This includes paths to the plugin's own static resources (images, fonts)
  # Patch the binary such that static resources will be loaded from a system dir:
  # Note: these paths can be located in the binary by hand via `strings TyrellN6.64.so`
  patch_strings_in_file "TyrellN6.64.so" "%s/.%s/%s/Data" "/opt/%3\$s/Data"
  patch_strings_in_file "TyrellN6.64.so" "%s/.%s/%s/Modules" "/opt/%3\$s/Modules"
  # This is for accessing the user guide & the dialog binaries
  patch_strings_in_file "TyrellN6.64.so" "%s/.%s/%s/" "/opt/%3\$s/"

  popd

  runHook postBuild
'';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -r TyrellN6 $out/share/TyrellN6

    mkdir -p $out/lib/vst3
    ln -s $out/share/TyrellN6/TyrellN6.64.so $out/lib/vst3/TyrellN6.64.so

    runHook postInstall
  '';
}
