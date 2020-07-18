{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, acpi
, conky
, dunst
, firefox
, libnotify
, neofetch
, nitrogen
, pciutils
, picom
, rangerplugins
, rofi
, st
, xfce4-power-manager
, zenity
}:
stdenv.mkDerivation {

  pname = "instantUtils";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantOS";
    rev = "fffe7a74cc09f19aea6b65bd35ed22b47e17ff39";
    sha256 = "1wm9wa66wzqjfh4wpk8i8ya2jy8x9xifzn8mds7k9y2q72mpc5gp";
    name = "instantOS_instantUtils";
  };

  postPatch = ''
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
      --replace /opt/instantos/menus "\$(instantdata -a)/opt/instantos/menus"
    substituteInPlace install.sh \
      --replace /usr/share/instantutils "$out/share/instantutils"
    substituteInPlace instantutils.sh \
      --replace /usr/share/instantutils "$out/share/instantutils"
    substituteInPlace installinstantos.sh \
      --replace /usr/share/instantutils "$out/share/instantutils"

  '';

  installPhase = ''
    runHook preInstall
    install -Dm 555 autostart.sh $out/bin/instantautostart
    install -Dm 555 status.sh $out/bin/instantstatus
    install -Dm 555 monitor.sh $out/bin/instantmonitor

    install -Dm 555 instantutils.sh $out/bin/instantutils
    install -Dm 555 installinstantos.sh $out/bin/installinstantos

    mkdir -p $out/share/instantutils
    chmod +x *.sh
    mv *.sh $out/share/instantutils
    chmod +x programs/*
    mv programs/* $out/bin

    mkdir -p $out/share/applications
    mv desktop/* $out/share/applications

    mkdir -p "$out/etc/X11/xorg.conf.d"
    mv xorg/* "$out/etc/X11/xorg.conf.d"
    runHook postInstall
  '';

  postInstall = ''
    # Wrapping PATHS
    wrapProgram "$out/bin/instantautostart" \
      --prefix PATH : ${lib.makeBinPath [ conky dunst libnotify xfce4-power-manager zenity ]} \
      --run export\ PATH="\"\$(instantdata -d)/bin\""\$\{PATH:\+\':\'\}\$PATH \
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
    '';

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = [ 
    acpi
    conky
    dunst
    firefox
    libnotify
    neofetch
    nitrogen
    picom
    rangerplugins
    st
    xfce4-power-manager
    zenity
  ];

  meta = with lib; {
    description = "instantOS Utils";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantOS";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
