{ stdenv
, bc
, bemenu
, bonsai
, conky
, dbus
, fetchgit
, gitUpdater
, gnugrep
, gojq
, inotify-tools
, j4-dmenu-desktop
, jq
, lib
, libnotify
, lisgd
, makeWrapper
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
, superd
, sway
, swayidle
, wob
, wvkbd
, xdg-user-dirs
, xdotool
}:

let
  # anything which any sxmo script or default hook in this package might invoke
  runtimeDeps = [
    bc
    bemenu
    bonsai
    conky
    dbus
    # dmenu  # or dmenu-wayland? only used on x11?
    gnugrep
    gojq
    inotify-tools
    j4-dmenu-desktop
    jq
    libnotify
    lisgd
    mako
    mepo  # mepo_ui_central_menu.sh
    modemmanager  # mmcli
    nettools  # netstat
    playerctl
    procps  # pgrep
    pulseaudio  # pactl
    sfeed
    superd
    sway
    swayidle
    wob
    wvkbd
    xdg-user-dirs

    # X11 only?
    xdotool
  ];
in
stdenv.mkDerivation rec {
  pname = "sxmo-utils";
  version = "1.14.2";

  src = fetchgit {
    url = "https://git.sr.ht/~mil/sxmo-utils";
    rev = version;
    hash = "sha256-1bGCUhf/bt9I8BjG/G7sjYBzLh28iZSC20ml647a3J4=";
  };

  patches = [
    # needed for basic use:
    ./0001-group-differs-from-user.patch
    ./0002-ensure-log-dir.patch
    ./0003-fix-xkb-paths.patch
    ./0004-no-busybox.patch
    # wanted to fix/silence some non-fatal errors
    ./0005-system-audio.patch
    ./0006-block-suspend-any-mpris.patch

    # personal (but upstreamable) preferences:
    ./0104-full-auto-rotate.patch
    ./0105-more-apps.patch
    ./0106-configurable-auto-screenoff.patch
  ];

  postPatch = ''
    sed -i 's@/usr/lib/udev/rules\.d@/etc/udev/rules.d@' Makefile
    sed -i "s@/etc/profile\.d/sxmo_init.sh@$out/etc/profile.d/sxmo_init.sh@" scripts/core/*.sh
    sed -i "s@/usr/bin/@@g" scripts/core/sxmo_version.sh
    sed -i 's:ExecStart=/usr/bin/:ExecStart=/usr/bin/env :' configs/superd/services/*.service
  '';

  nativeBuildInputs = [
    makeWrapper
    scdoc
  ];

  installFlags = [
    "OPENRC=0"
    "DESTDIR=$(out)"
    "PREFIX="
  ];

  # we don't wrap sxmo_common.sh or sxmo_init.sh
  # which is unfortunate, for non-sxmo-utils files that might source though.
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
