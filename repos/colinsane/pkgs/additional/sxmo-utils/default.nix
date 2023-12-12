{ stdenv
, bash
, bc
, bemenu
, bonsai
, brightnessctl
, buildPackages
, busybox
, codemadness-frontends_0_6 ? null  # 2023-11-28: alpine is stuck at 0.6, and i think it exposes a different API
, conky
, coreutils
, curl
, dbus
, dmenu
, fetchFromSourcehut
, fetchpatch
, gnugrep
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
, modemmanager
, nettools
, networkmanager
, playerctl
, procps
, pulseaudio
, rsync
, scdoc
, scrot
, sfeed
, slurp
, superd
, sway
, swayidle
, systemd
, unstableGitUpdater
, upower
, wob
, wl-clipboard
, wtype
, wvkbd
, xdg-user-dirs
, xdotool
, xrdb
, supportSway ? true
, supportDwm ? false
, preferSystemd ? false
}:

let
  # anything which any sxmo script or default hook in this package might invoke
  runtimeDeps = [
    bc  # also in busybox
    bonsai
    brightnessctl
    codemadness-frontends_0_6  # for sxmo_youtube.sh
    conky
    curl
    dbus
    gnugrep  # also in busybox
    inotify-tools
    j4-dmenu-desktop
    jq
    libnotify
    libxml2.bin  # for xmllint; sxmo_weather.sh, sxmo_surf_linkset.sh
    lisgd
    mako
    modemmanager  # mmcli
    nettools  # netstat
    networkmanager  # nmcli
    playerctl
    procps  # pgrep
    pulseaudio  # pactl
    sfeed
    upower  # used by sxmo_battery_monitor.sh, sxmo_hook_battery.sh
    wob
    xdg-user-dirs  # used by sxmo_hook_start.sh
    xrdb  # for sxmo_xinit AND sxmo_winit
  ] ++ (
    if preferSystemd then [ systemd ] else [ superd ]
  ) ++ lib.optionals supportSway [
    bemenu
    grim
    slurp  # for sxmo_screenshot.sh
    sway
    swayidle
    wl-clipboard  # for wl-copy; sxmo_screenshot.sh
    wtype  # for sxmo_type
    wvkbd  # sxmo_winit.sh
  ] ++ lib.optionals supportDwm [
    dmenu
    scrot  # sxmo_screenshot.sh
    xdotool
  ];
in
stdenv.mkDerivation rec {
  pname = "sxmo-utils";
  version = "unstable-2023-12-09";

  src = fetchFromSourcehut {
    owner = "~mil";
    repo = "sxmo-utils";
    rev = "97447367f6465de3759144ffe30d449d095ee479";
    hash = "sha256-cQxjsqGqx9U97B9EvD5UhFwKEGBOGLVqtvW/34aFXuw=";
  };

  patches = [
    (fetchpatch {
      name = "only alias jq=gojq if the latter is available";
      url = "https://git.uninsane.org/colin/sxmo-utils/commit/e0caaeb4219ba3b92d358a16dfa85bcd09a89adf.patch";
      hash = "sha256-EuJeHEEmewpipfpEy54pmyBaxhu5KBg7rX5n2kg+iMs=";
    })
    (fetchpatch {
      name = "sxmo_hook_apps: add a few";
      url = "https://git.uninsane.org/colin/sxmo-utils/commit/1c2e13401e28e3713665de6ce8f591714e65341d.patch";
      hash = "sha256-6OsHbjv2YZ1WueIlwDIRjgSTAN+UIZFHcvMhMbj6kfc=";
    })

    (fetchpatch {
      name = "sxmo_migrate: add option to disable configversion checks";
      url = "https://lists.sr.ht/~mil/sxmo-devel/patches/44155/mbox";
      hash = "sha256-ZcUD2UWPM8PxGM9TBnGe8JCJgMC72OZYzctDf2o7Ub0=";
    })

    (fetchpatch {
      # experimental patch to launch apps via `swaymsg exec -- `
      # this allows them to detach from sxmo_appmenu.sh (so, `pstree` looks cleaner)
      # and more importantly they don't inherit the environment of sxmo internals (i.e. PATH).
      # suggested by Aren in #sxmo.
      #
      # old pstree look:
      # - sxmo_hook_inputhandler.sh volup_one
      #   - sxmo_appmenu.sh
      #     - sxmo_appmenu.sh applications
      #       - <application, e.g. chatty>
      name = "sxmo_hook_apps: launch apps via the window manager";
      url = "https://git.uninsane.org/colin/sxmo-utils/commit/0087acfecedf9d1663c8b526ed32e1e2c3fc97f9.patch";
      hash = "sha256-YwlGM/vx3ZrBShXJJYuUa7FTPQ4CFP/tYffJzUxC7tI=";
    })
    # (fetchpatch {
    #   name = "sxmo_log: print to console";
    #   url = "https://git.uninsane.org/colin/sxmo-utils/commit/030280cb83298ea44656e69db4f2693d0ea35eb9.patch";
    #   hash = "sha256-dc71eztkXaZyy+hm5teCw9lI9hKS68pPoP53KiBm5Fg=";
    # })
  ];

  postPatch = ''
    # allow sxmo to source its init file
    sed -i "s@/etc/profile\.d/sxmo_init.sh@$out/etc/profile.d/sxmo_init.sh@" scripts/core/*.sh
    # remove absolute paths
    substituteInPlace scripts/core/sxmo_version.sh \
      --replace "/usr/bin/" ""

    # let superd find sxmo service binaries at runtime via PATH
    # TODO: replace with fully-qualified paths
    sed -i 's:ExecStart=/usr/bin/:ExecStart=/usr/bin/env :' \
      configs/services/*.service \
      configs/superd/services/*.service

    # install udev rules to where nix expects
    substituteInPlace Makefile \
      --replace "/usr/lib/udev/rules.d" "/etc/udev/rules.d"
    # avoid relative paths in udev rules
    substituteInPlace configs/udev/90-sxmo.rules \
      --replace "/bin/chgrp" "${coreutils}/bin/chgrp" \
      --replace "/bin/chmod" "${coreutils}/bin/chmod"
  '' + lib.optionalString preferSystemd ''
    shopt -s globstar
    sed -i 's/superctl status "$1" | grep -q started/systemctl --user is-active --quiet "$1"/g' **/*.sh
    sed -i 's/superctl/systemctl --user/g' **/*.sh
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
    # TODO: use SERVICEDIR and EXTERNAL_SERVICES=0 to integrate superd/systemd better
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
          # these are sourced by other scripts: don't wrap them else the `exec` in the nix wrapper breaks the outer script
        ;;
        (*)
          wrapProgram "$f" \
            --suffix PATH : "${lib.makeBinPath runtimeDeps}"
        ;;
      esac
    done
  '';

  passthru = {
    inherit runtimeDeps;
    providedSessions = (lib.optional supportSway "swmo") ++ (lib.optional supportDwm "sxmo");
    updateScript = unstableGitUpdater { };
  };

  meta = {
    homepage = "https://git.sr.ht/~mil/sxmo-utils";
    description = "Contains the scripts and small C programs that glues the sxmo enviroment together";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.linux; 
  };
}
