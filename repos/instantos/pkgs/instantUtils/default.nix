{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, makeWrapper
, acpi
, autorandr
, conky , dunst , firefox
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
, st
, wmctrl
, xfce4-power-manager
, zenity
}:
let
  thanks = stdenv.mkDerivation {
    pname = "instantOS-thanks";
    version = "unstable";

    src = fetchurl {
      url = "https://raw.githubusercontent.com/instantOS/instantLOGO/ae4626d6e67d078657389c290db8c29d234f8250/description/thanks.txt";
      sha256 = "0h65x0g4wglkrw457sid0ycjc09pq1knicx9fzn35q9wr77yqkki";
    };
    sourceRoot = ".";
    unpackCmd =  "cp $curSrc thanks.txt";

    installPhase = ''
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
      url = "https://raw.githubusercontent.com/instantOS/instantos.github.io/0c6a883a2ac019e9d4b3973db1e71b1d43a161a6/youtube/hotkeys.md";
      sha256 = "1qi0qxs1s7g3461al6r45nm8x7kavlzqgpfhcd6j7y8pn8pgy6ha";
    };
    sourceRoot = ".";
    unpackCmd =  "cp $curSrc hotkeys.md";

    postPatch = ''
      cat hotkeys.md | \
        sed 's/^\([^|#]\)/    \1/g'  | \
        sed 's/^##*[ ]*/ /g' > hotkeys.md
    '';

    installPhase = ''
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
    rev = "9f6b37b59effbf8583f354efcd9d99d68ef74106";
    sha256 = "0svwcvrlldqwyljnbfslvhkbh4pdjpxnj9czwvlyy4ws1vszkh20";
    name = "instantOS_instantUtils";
  };

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = [
    acpi
    autorandr
    conky
    dunst
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
    zenity

    thanks
    keybindings
  ];

  postPatch = ''
    for fl in *.sh programs/ifeh; do
    substituteInPlace "$fl" \
      --replace "#!/usr/bin/dash" "#!/bin/sh"
    done
    substituteInPlace programs/appmenu \
      --replace "#!/usr/bin/dash" "#!/bin/sh" \
      --replace "/usr/share/instantdotfiles/rofi/appmenu.rasi" "tmp_placeholder" \
      --replace "tmp_placeholder" "\$(instantdata -d)/share/instantdotfiles/rofi/appmenu.rasi"
    substituteInPlace autostart.sh \
      --replace /usr/bin/instantstatus "$out/bin/instantstatus" \
      --replace /usr/share/instantutils "$out/share/instantutils" \
      --replace /usr/share/rangerplugins "${rangerplugins}/share/rangerplugins" \
      --replace /usr/share/instantwidgets "\$(instantdata -wi)/share/instantwidgets" \
      --replace /usr/share/instantwallpaper "\$(instantdata -wa)/share/instantwidgets" \
      --replace /usr/share/instantassist/assists "\$(instantdata -a)/share/instantassist/assists"
    substituteInPlace instantutils.sh \
      --replace /usr/share/instantutils "$out/share/instantutils"
    substituteInPlace installinstantos.sh \
      --replace /usr/share/instantutils "$out/share/instantutils"
    patchShebangs *.sh
  '';

  installPhase = ''
    runHook preInstall
    install -Dm 555 autostart.sh "$out/bin/instantautostart"
    install -Dm 555 status.sh "$out/bin/instantstatus"
    install -Dm 555 monitor.sh "$out/bin/instantmonitor"

    install -Dm 555 instantutils.sh "$out/bin/instantutils"
    install -Dm 555 installinstantos.sh "$out/bin/installinstantos"

    mkdir -p "$out/share/instantutils"
    chmod +x *.sh
    mv *.sh "$out/share/instantutils"

    chmod +x setup/*
    mv setup "$out/share/instantutils"
    ln -s "${thanks}/thanks.txt" "$out/share/instantutils/thanks.txt"
    mv mirrors "$out/share/instantutils"
    echo "${version}" > "$out/share/instantutils/version"

    mkdir -p "$out/share/applications"
    mv desktop/* "$out/share/applications"

    chmod +x programs/*
    mv programs/* "$out/bin"

    ln -s "${keybindings}/hotkeys.md" "$out/share/instantutils/keybinds"

    mkdir -p "$out/etc/X11/xorg.conf.d"
    mv xorg/* "$out/etc/X11/xorg.conf.d"
    runHook postInstall
  '';

  postInstall = ''
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
    wrapProgram "$out/share/instantutils/userinstall.sh" \
      --prefix PATH : ${lib.makeBinPath [ acpi pciutils ]}
    wrapProgram "$out/bin/ipicom" \
      --prefix PATH : ${lib.makeBinPath [ picom ]}
    wrapProgram "$out/bin/iswitch" \
      --prefix PATH : ${lib.makeBinPath [ wmctrl ]}
    wrapProgram "$out/bin/instantstatus" \
      --prefix PATH : ${lib.makeBinPath [ acpi ]}
  '';

  meta = with lib; {
    description = "instantOS Utils";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantOS";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
