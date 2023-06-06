{ stdenv
, fetchgit
, gitUpdater
, lib
, rsync
}:

stdenv.mkDerivation rec {
  pname = "sxmo-utils";
  version = "1.14.1";

  src = fetchgit {
    url = "https://git.sr.ht/~mil/sxmo-utils";
    rev = version;
    hash = "sha256-UcJid1fi3Mgu32dCqlI9RQYnu5d07MMwW3eEYuYVBw4=";
  };

  patches = [
    # needed for basic use:
    ./0001-group-differs-from-user.patch
    ./0002-ensure-log-dir.patch
    ./0003-fix-xkb-paths.patch
    ./0004-no-busybox.patch

    # personal preferences:
    ./0104-full-auto-rotate.patch
  ];

  postPatch = ''
    sed -i 's@/usr/lib/udev/rules\.d@/etc/udev/rules.d@' Makefile
    sed -i "s@/etc/profile\.d/sxmo_init.sh@$out/etc/profile.d/sxmo_init.sh@" scripts/core/*.sh
    sed -i "s@/usr/bin/@@g" scripts/core/sxmo_version.sh
    sed -i 's:ExecStart=/usr/bin/:ExecStart=/usr/bin/env :' configs/superd/services/*.service

    # apply customizations
    # - xkb_mobile_normal_buttons:
    #   - on devices where volume is part of the primary keyboard (e.g. thinkpad), we want to avoid overwriting the default map
    #   - this provided map is the en_US 105 key map
    ${rsync}/bin/rsync -rlv ${./customization}/ ./
  '';

  installFlags = [
    "OPENRC=0"
    "DESTDIR=$(out)"
    "PREFIX="
  ];

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
