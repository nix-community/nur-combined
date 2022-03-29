{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, makeWrapper
, acpi
, autorandr
, conky
, dunst
, firefox
, libnotify
, lxsession
, neofetch
, networkmanagerapplet
, nitrogen
, pciutils
, picom
, rangerplugins
, rofi
, rox-filer
, disper
, st
, slock
, wmctrl
, xfce4-power-manager
, upower
, zenity
, extraPatches ? []
, defaultApps ? {}
}:
let

  defaults = {
   terminal = "st";
   graphicaleditor = "'st -e nvim'";
   appmenu = "appmenu";
   browser = "firefox";
   filemanager = "nautilus";
   systemmonitor = "'st -e htop'";
   editor = "'st -e nvim'";
   termeditor = "nvim";
   lockscreen = "${slock}/bin/slock";
  } // defaultApps;

  thanks = stdenv.mkDerivation {
    pname = "instantOS-thanks";
    version = "unstable";

    src = fetchurl {
      url = "https://raw.githubusercontent.com/instantOS/instantLOGO/014673c0d7cc62a35b639bb308f23d2c8d8b74a5/description/thanks.txt";
      sha256 = "sha256-q1pttBrCgsX8xk0CPTy0MWl/5MJN3NTFkvtoypbca1Q=";
    };
    sourceRoot = ".";
    unpackCmd =  "cp $curSrc thanks.txt";

    installPhase = ''
      echo THANKS
      ls -lh
      install -Dm 644 thanks.txt "$out/thanks.txt";
    '';

    meta = with lib; {
      description = "Thanks file";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };
  keybindings = stdenv.mkDerivation {
    pname = "instantOS-keybindings";
    version = "unstable";

    src = fetchurl {
      url = "https://raw.githubusercontent.com/instantOS/instantos.github.io/4deb9b368108999067bfc60c5e6e1d0e36fea0ab/youtube/hotkeys.md";
      sha256 = "sha256-WJopJ6qMeUWV7o+J6/CptfdbabnCbx+a6nsL6mbxsOE=";
    };
    sourceRoot = ".";
    unpackCmd =  "cp $curSrc hotkeys.md";

    postPatch = ''
      cat hotkeys.md | \
        sed 's/^\([^|#]\)/    \1/g'  | \
        sed 's/^##*[ ]*/ /g' > hotkeys.md
    '';

    installPhase = ''
      echo HOTKEYS
      ls -lh
      install -Dm 644 hotkeys.md "$out/hotkeys.md";
    '';

    meta = with lib; {
      description = "Hotkeys file";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };
in
stdenv.mkDerivation rec {

  pname = "instantUtils";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantOS";
    rev = "188d22a462ba7436775a619c635b7129f275ece3";
    sha256 = "ucyad0SDLrxae9jJv3q917pWfrpDk97A8Uo7NSnlWMs=";
    name = "instantOS_instantUtils";
  };

  patches = extraPatches;

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = [
    acpi
    autorandr
    conky
    dunst
    disper
    firefox
    libnotify
    lxsession
    neofetch
    networkmanagerapplet
    nitrogen
    pciutils
    picom
    rangerplugins
    rofi
    rox-filer
    st
    wmctrl
    xfce4-power-manager
    upower
    zenity

    thanks
    keybindings
  ];

  postPatch = ''
    for fl in *.sh programs/ifeh; do
      substituteInPlace "$fl" \
        --replace "#!/usr/bin/dash" "#!/bin/sh"
    done
    substituteInPlace programs/instantstartmenu \
      --replace "/usr/share/instantutils/thanks.txt" "${thanks}/thanks.txt"
    substituteInPlace programs/appmenu \
      --replace "#!/usr/bin/dash" "#!/bin/sh" \
      --replace "/usr/share/instantdotfiles/rofi/appmenu.rasi" "tmp_placeholder" \
      --replace "tmp_placeholder" "\$(instantdata --get-userconfig-dir=rofi)/appmenu.rasi"
    substituteInPlace autostart.sh \
      --replace /usr/bin/instantstatus "$out/bin/instantstatus" \
      --replace /usr/share/instantutils "$out/share/instantutils" \
      --replace /usr/share/rangerplugins "${rangerplugins}/share/rangerplugins" \
      --replace /usr/share/instantwidgets "\$(instantdata -wi)/share/instantwidgets" \
      --replace /usr/share/instantwallpaper "\$(instantdata -wa)/share/instantwidgets" \
      --replace /usr/share/instantassist/assists "\$(instantdata -a)/share/instantassist/assists" \
      --replace /opt/instantos/rootinstall "$out/share/instantutils"
    sed -i 's/^\s*setxkbmap\s\+-layout.*$/:;/' autostart.sh
    substituteInPlace instantutils.sh \
      --replace /usr/share/instantutils "$out/share/instantutils"
    substituteInPlace installinstantos.sh \
      --replace /usr/share/instantutils "$out/share/instantutils"
    substituteInPlace setup/defaultapps \
      --replace "setprogram terminal st" "setprogram terminal ${defaults.terminal}" \
      --replace "setprogram graphicaleditor code" "setprogram graphicaleditor ${defaults.graphicaleditor}" \
      --replace "setprogram editor nvim-qt" "setprogram editor ${defaults.editor}" \
      --replace "setprogram termeditor nvim" "setprogram termeditor ${defaults.termeditor}" \
      --replace "setprogram appmenu appmenu" "setprogram appmenu ${defaults.appmenu}" \
      --replace "setprogram browser firefox" "setprogram browser ${defaults.browser}" \
      --replace "setprogram filemanager nautilus" "setprogram filemanager ${defaults.filemanager}" \
      --replace "setprogram systemmonitor mate-system-monitor" "setprogram systemmonitor ${defaults.systemmonitor}" \
      --replace "setprogram lockscreen ilock" "setprogram lockscreen ${defaults.lockscreen}"
    patchShebangs *.sh
  '';

  dontBuild = true;

  makeFlags = [ "DESTDIR=$(out)" "PREFIX=" ];

  installTargets = [ "install_local" ];

  installPhase = ''
    runHook preInstall
    make install_local DESTDIR=$out PREFIX=
    runHook postInstall
  '';

  postInstall = ''
    ln -s "${thanks}/thanks.txt" "$out/share/instantutils/thanks.txt"
    ln -s "${keybindings}/hotkeys.md" "$out/share/instantutils/keybinds"
    echo "${version}" > "$out/share/instantutils/version"
    # Wrapping PATHS
    wrapProgram "$out/bin/instantautostart" \
      --prefix PATH : ${lib.makeBinPath [
          autorandr
          conky
          dunst
          libnotify
          lxsession
          networkmanagerapplet
          rox-filer
          xfce4-power-manager
          zenity
        ]} \
      --run export\ PATH="\$(instantdata -d)/bin"\$\{PATH:\+\':\'\}\$PATH \
      --run export\ PATH="\"\$(instantdata -s)/bin\""\$\{PATH:\+\':\'\}\$PATH \
      --run export\ PATH="\"\$(instantdata -t)/bin\""\$\{PATH:\+\':\'\}\$PATH
    wrapProgram "$out/bin/instantstartmenu" \
      --prefix PATH : ${lib.makeBinPath [ firefox neofetch st ]}
    wrapProgram "$out/bin/appmenu" \
      --prefix PATH : ${lib.makeBinPath [ rofi ]}
    wrapProgram "$out/bin/ifeh" \
      --prefix PATH : ${lib.makeBinPath [ nitrogen ]}
    #wrapProgram "$out/share/instantutils/userinstall.sh" \
    #  --prefix PATH : ${lib.makeBinPath [ acpi pciutils ]}
    wrapProgram "$out/bin/ipicom" \
      --prefix PATH : ${lib.makeBinPath [ picom ]}
    wrapProgram "$out/bin/iswitch" \
      --prefix PATH : ${lib.makeBinPath [ wmctrl ]}
    wrapProgram "$out/bin/instantstatus" \
      --prefix PATH : ${lib.makeBinPath [ acpi ]}
    wrapProgram "$out/bin/instantdisper" \
      --prefix PATH : ${lib.makeBinPath [ disper dunst ]}
  '';

  meta = with lib; {
    description = "instantOS Utils";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantOS";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
