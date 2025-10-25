{
  autoPatchelfHook,
  buildFHSEnvChroot ? false,
  buildFHSUserEnv ? false,
  dpkg,
  fetchurl,
  lib,
  stdenv,
  sysctl,
  iptables,
  iproute2,
  procps,
  cacert,
  libxml2,
  libidn2,
  libnl,
  libcap,
  libcap_ng,
  zlib,
  sqlite,
  wireguard-tools,
}:

let
  pname = "nordvpn";
  version = "4.2.0";
  wingej0 = {
    name = "Jeff Winget";
    email = "wingej0@gmail.com";
    github = "wingej0";
    githubId = 19930583;
  };
  buildEnv =
    if builtins.typeOf buildFHSEnvChroot == "set" then buildFHSEnvChroot else buildFHSUserEnv;

  # FIX 1: Moved libxml2_13 definition up
  libxml2_13 = libxml2.overrideAttrs rec {
    version = "2.13.8";
    src = fetchurl {
      url = "mirror://gnome/sources/libxml2/${lib.versions.majorMinor version}/libxml2-${version}.tar.xz";
      hash = "sha256-J3KUyzMRmrcbK8gfL0Rem8lDW4k60VuyzSsOhZoO6Eo=";
    };
    patches = []; # FIX 2: Added to stop patchPhase failure
  };

  nordVPNBase = stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/n/nordvpn/nordvpn_${version}_amd64.deb";
      hash = "sha256-NIaZuM1gy2PoqmJYzluFwSzsXvaPZZ2dnh2uF003H+o=";
    };

    buildInputs = [
      libxml2_13 # Correctly uses the overridden version
      libidn2
      libnl
      libcap
      libcap_ng
      sqlite
    ];

    nativeBuildInputs = [
      dpkg
      autoPatchelfHook
      stdenv.cc.cc.lib
      libxml2 # This is fine, it's for the build tools
    ];

    dontConfigure = true;
    dontBuild = true;

    unpackPhase = ''
      runHook preUnpack
      dpkg --extract $src .
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      mv usr/* $out/
      mv var/ $out/
      mv etc/ $out/
      runHook postInstall
    '';
  };

  nordVPNfhs = buildEnv {
    name = "nordvpnd";
    runScript = "nordvpnd";

    # hardcoded path to /sbin/ip
    targetPkgs =
      pkgs: with pkgs; [
        nordVPNBase
        sysctl
        iptables
        iproute2
        procps
        cacert
        libxml2_13 # FIX 3: Changed from libxml2 to match nordVPNBase
        libidn2
        zlib
        wireguard-tools
        sqlite
      ];
  };

in
stdenv.mkDerivation {
  inherit pname version;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share
    ln -s ${nordVPNBase}/bin/nordvpn $out/bin
    ln -s ${nordVPNfhs}/bin/nordvpnd $out/bin
    ln -s ${nordVPNBase}/share* $out/share
    ln -s ${nordVPNBase}/var $out/
    runHook postInstall
  '';

  meta = with lib; {
    description = "CLI client for NordVPN";
    homepage = "https://www.nordvpn.com";
    license = licenses.unfree;
    maintainers = with maintainers; [ wingej0 ];
    platforms = [ "x86_64-linux" ];
  };
}