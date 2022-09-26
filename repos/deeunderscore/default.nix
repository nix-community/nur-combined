{ pkgs ? import <nixpkgs> {} }:
rec {
    faq = pkgs.callPackage ./pkgs/faq { };
    git-archive-all = pkgs.callPackage ./pkgs/git-archive-all { };
    moar = pkgs.callPackage ./pkgs/moar { };
    rdrview = pkgs.callPackage ./pkgs/rdrview { };
    slit = pkgs.callPackage ./pkgs/slit { };
    uniutils = pkgs.callPackage ./pkgs/uniutils { };
    libuiohook = pkgs.callPackage ./pkgs/libuiohook { };
    obs-input-overlay = pkgs.libsForQt5.callPackage ./pkgs/obs-input-overlay { };
    linx-client = pkgs.callPackage ./pkgs/linx-client { };
    nheko-unstable = pkgs.libsForQt5.callPackage ./pkgs/nheko { inherit coeurl; mtxclient = mtxclient-unstable; };
    coeurl = pkgs.callPackage ./pkgs/coeurl { };
    mtxclient-unstable = pkgs.callPackage ./pkgs/mtxclient { inherit coeurl; };
    pktriggercord = pkgs.callPackage ./pkgs/pktriggercord { };
    jday = pkgs.callPackage ./pkgs/jday { };
    geographiclib-cpp = pkgs.callPackage ./pkgs/geographiclib-cpp { };
}
