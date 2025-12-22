{ lib
, pkgs
, cljNix
, fetchFromGitHub
, jdk21
, leiningen
, makeWrapper
, jre
, gtk3
, glib
, gsettings-desktop-schemas
, wrapGAppsHook3
, symlinkJoin
}:
let 
  cloojBase = cljNix.lib.mkCljApp {
    pkgs = pkgs;


    modules = [
      {
        # Point to the *Clooj sources you want to build*
        # If you keep deps.edn + deps-lock.json alongside sources, this is easy:
        # name should be namespaced
        name = "clj-commons/clooj";
        version = "0.5.0";

        projectSrc = fetchFromGitHub {
          owner = "SZanko";
          repo = "clooj";
          rev = "966ed9bd0efedd97735274f3eb95b9051a9497bf";
          hash = "sha256-mMn/Qpxbr6Vcv1WA/iespxp8YkEJILobmcJ165Xah3E=";
        };

        lockfile = ./deps-lock.json;

        # Clooj's main namespace (must have -main and :gen-class for mkCljBin checks)
        # You likely want: "clooj.core"
        main-ns = "clooj.core";

        jdk = jdk21;

        withLeiningen = true;

        # Override build command to use lein (optional, only if default tools.build doesn't work)
        buildCommand = ''
        export HOME=$TMPDIR
        export JAVA_TOOL_OPTIONS="$JAVA_TOOL_OPTIONS -Djava.util.prefs.userRoot=$TMPDIR/.java-prefs"


        lein uberjar
        export jarPath="$(find "$PWD/target" -maxdepth 1 -name '*-standalone.jar' -print -quit)"
        test -n "$jarPath"
        '';

      }
    ];

  };
in

  symlinkJoin {
    name = "clooj-0.5.0";

    paths = [ cloojBase ];

    nativeBuildInputs = [ leiningen makeWrapper wrapGAppsHook3 ];
    buildInputs = [ jre gtk3 glib gsettings-desktop-schemas ];

    # Use postFixup so it runs after paths are linked into $out
    postFixup = ''
      set -eu

      if [ ! -e "$out/bin/clooj" ]; then
        echo "ERROR: $out/bin/clooj not found"
        ls -la "$out/bin" || true
        exit 1
      fi

      if [ -L "$out/bin/clooj" ]; then
        target="$(readlink -f "$out/bin/clooj")"
        rm -f "$out/bin/clooj"
      else
        target="$out/bin/.clooj-real"
        mv "$out/bin/clooj" "$target"
      fi

      makeWrapper "$target" "$out/bin/clooj" \
        --prefix XDG_DATA_DIRS : "${gsettings-desktop-schemas}/share" \
        --prefix XDG_DATA_DIRS : "${gtk3}/share" \
        --prefix XDG_DATA_DIRS : "${glib}/share"
    '';

    dontWrapGApps = false;

    meta = {
      description = "Clooj, a lightweight IDE for clojure";
      homepage = "https://github.com/clj-commons/clooj";
      license = lib.licenses.epl10;
      maintainers =
        let m = lib.maintainers or {};
        in lib.optionals (m ? szanko) [ m.szanko ];
      mainProgram = "clooj";
      platforms = lib.platforms.all;
    };
  }
