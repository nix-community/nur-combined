{ lib, writeShellScriptBin, makeDesktopItem, symlinkJoin,
  yad,
  firefox,
  firefoxProfiles ? [ "Default" ],
  firefoxTmpProfileDir ? "~/.mozilla/firefox/TMP/"
}:

let
  profilesWithNumbers = builtins.genList (i: toString (i+1) + " \"" + (builtins.elemAt firefoxProfiles i) + "\"") (builtins.length firefoxProfiles);
  allProfiles = builtins.concatStringsSep " " profilesWithNumbers;

  startFirefox = writeShellScriptBin "startFirefox"
    ''
      FIREFOX_TMP="${firefoxTmpProfileDir}"

      confirm() {
        # call with a prompt string or use a default
        response="$(${yad}/bin/yad --splash --entry --title "Confirm" --text "''${1:-Are you sure? [Y/N]} ")"
        case "$response" in
          [yY][eE][sS]|[yY]|[jJ])
            true
            ;;
          [nN][oO]|[nN])
            false
            ;;
          *)
            confirm "$@"
        esac
      }

      if [ "$1" == "" ]
      then
        site="about:blank"
      else
        site="$1"
      fi

      profile="$(${yad}/bin/yad --splash --height 300 --list --separator="" --title="Firefox Profile" --text="$site - Open with?" --search-column=1 --print-column=2 --column="Number:NUM" --column "Profile:TEXT" ${allProfiles})"

      if [ "$profile" == "" ]; then
        exit 2
      fi

      modeRaw="-new-window"

      if [ ! "$1" == "" ]
      then
        if ! ${yad}/bin/yad --splash --question --text="$profile - Open new Window?" --title "Window?" --default-cancel
        then
            modeRaw="-new-tab"
        fi
      fi

      if [ "$profile" == "TMP" ]
      then
        confirm "Reset? (Y/N) " && rm -r $FIREFOX_TMP && mkdir $FIREFOX_TMP
      fi

      ${firefox}/bin/firefox -P "$profile" "$modeRaw" "$site"
    '';
  desktopItem = makeDesktopItem {
    name = "Firefox";
    exec = "${startFirefox}/bin/startFirefox %u";
    icon = "firefox";
    comment = "Browse the web";
    desktopName = "Firefox";
    genericName = "Web Browser";
    categories = ["Network" "WebBrowser"];
    keywords = ["web" "browser" "internet"];
    mimeTypes = ["text/html" "text/xml" "application/xhtml+xml" "application/vnd.mozilla.xul+xml" "text/mml" "x-scheme-handler/http" "x-scheme-handler/https"];
    startupNotify = true;
    startupWMClass = "Firefox";
  };
in symlinkJoin {
  name = "startFirefox";
  paths = [ startFirefox ];

  postBuild =
    ''
      mkdir -p $out/share/applications
      cp ${desktopItem}/share/applications/* $out/share/applications
    '';

  meta = with lib; {
    descripytion = "A firefox launcher.";
    longDescription = ''Let's you choose the firefox profile before starting.'';
    homepage = "https://github.com/neumantm/nur-packages";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
