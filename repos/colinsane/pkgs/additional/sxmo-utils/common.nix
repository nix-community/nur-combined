{ stdenv
, bash
, bc
, bemenu
, bonsai
, brightnessctl
, buildPackages
, busybox
, conky
, coreutils
, curl
, dbus
, fetchgit
, fetchpatch
, gitUpdater
, gnugrep
, gojq
, grim
, inotify-tools
, j4-dmenu-desktop
, jq
, lib
, libnotify
, libxml2
, lisgd
, makeBinaryWrapper
, mako
, mepo
, modemmanager
, nettools
, playerctl
, procps
, pulseaudio
, rsync
, scdoc
, sfeed
, slurp
, superd
, sway
, swayidle
, wob
, wl-clipboard
, wtype
, wvkbd
, xdg-user-dirs
, xdotool
, xrdb

, version
, rev ? version
, hash ? ""
, patches ? []
}:

let
  # anything which any sxmo script or default hook in this package might invoke
  runtimeDeps = [
    bc  # also in busybox
    bemenu
    bonsai
    brightnessctl
    conky
    curl
    dbus
    # dmenu  # or dmenu-wayland? only used on x11?
    gnugrep  # also in busybox
    gojq
    grim
    inotify-tools
    j4-dmenu-desktop
    jq
    libnotify
    libxml2.bin  # for xmllint; sxmo_weather.sh, sxmo_surf_linkset.sh
    lisgd
    mako
    mepo  # mepo_ui_central_menu.sh
    modemmanager  # mmcli
    nettools  # netstat
    playerctl
    procps  # pgrep
    pulseaudio  # pactl
    sfeed
    slurp  # for sxmo_screenshot.sh
    superd
    sway
    swayidle
    wl-clipboard  # for wl-copy; sxmo_screenshot.sh
    wob
    wtype  # for sxmo_type
    wvkbd
    xdg-user-dirs  # used by sxmo_hook_start.sh
    xrdb  # for sxmo_xinit AND sxmo_winit

    # X11 only?
    xdotool
  ];
in
stdenv.mkDerivation rec {
  pname = "sxmo-utils";
  inherit version;

  src = fetchgit {
    url = "https://git.sr.ht/~mil/sxmo-utils";
    inherit rev hash;
  };

  inherit patches;

  postPatch = ''
    # allow sxmo to source its init file
    sed -i "s@/etc/profile\.d/sxmo_init.sh@$out/etc/profile.d/sxmo_init.sh@" scripts/core/*.sh
    # remove absolute paths
    substituteInPlace scripts/core/sxmo_version.sh \
      --replace "/usr/bin/" ""

    # let superd find sxmo service binaries at runtime via PATH
    # TODO: replace with fully-qualified paths
    sed -i 's:ExecStart=/usr/bin/:ExecStart=/usr/bin/env :' configs/superd/services/*.service

    # install udev rules to where nix expects
    substituteInPlace Makefile \
      --replace "/usr/lib/udev/rules.d" "/etc/udev/rules.d"
    # avoid relative paths in udev rules
    substituteInPlace configs/udev/90-sxmo.rules \
      --replace "/bin/chgrp" "${coreutils}/bin/chgrp" \
      --replace "/bin/chmod" "${coreutils}/bin/chmod"
  '';

  nativeBuildInputs = [
    makeBinaryWrapper
    scdoc
  ];

  buildInputs = [ bash ];  # needed here so stdenv's `patchShebangsAuto` hook sets the right interpreter

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "SYSCONFDIR=${placeholder "out"}/etc"
    "DESTDIR="
    "OPENRC=0"
  ];
  preInstall = ''
    # busybox is used by setup_config_version.sh, but placing it in nativeBuildInputs breaks the nix builder
    PATH="$PATH:${buildPackages.busybox}/bin"
  '';

  # we don't wrap sxmo_common.sh or sxmo_init.sh
  # which is unfortunate, for non-sxmo-utils files that might source those.
  # if that's a problem, could inject a PATH=... line into them with sed.
  postInstall = ''
    for f in \
      $out/bin/*.sh \
      $out/share/sxmo/default_hooks/desktop/sxmo_hook_*.sh \
      $out/share/sxmo/default_hooks/one_button_e_reader/sxmo_hook_*.sh \
      $out/share/sxmo/default_hooks/three_button_touchscreen/sxmo_hook_*.sh \
      $out/share/sxmo/default_hooks/sxmo_hook_*.sh \
    ; do
      case $(basename $f) in
        (sxmo_common.sh|sxmo_deviceprofile_*.sh|sxmo_hook_icons.sh|sxmo_init.sh)
          # these are sourced by other scripts: don't wrap them else the `exec` in the wrapper breaks the outer script
        ;;
        (*)
          wrapProgram "$f" \
            --prefix PATH : "${lib.makeBinPath runtimeDeps}"
        ;;
      esac
    done
  '';

  passthru = {
    providedSessions = [ "sxmo" "swmo" ];
    updateScript = gitUpdater { };
  };

  meta = {
    homepage = "https://git.sr.ht/~mil/sxmo-utils";
    description = "Contains the scripts and small C programs that glues the sxmo enviroment together";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.linux; 
  };
}
