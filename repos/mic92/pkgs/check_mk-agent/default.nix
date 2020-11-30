{ stdenv
, fetchurl
, makeWrapper
, coreutils
, gnused
, gnugrep
, perl
  # all these are optional
, ethtool ? null
, zfs ? null
, ipmitool ? null
, lvm2 ? null
, postfix ? null
, extraPackages ? [ ]
}:
stdenv.mkDerivation rec {
  pname = "check_mk-agent";
  version = "1.6.0p11";

  src = fetchurl {
    url = "https://checkmk.com/support/${version}/check-mk-raw-${version}.cre.tar.gz";
    sha256 = "19k1ivxrf41x5zy3fr5c6w2cdfzwaf9lhhwh3r48n5vp62l6fqfr";
  };

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    sed -i -e 's!/bin/bash!bash!' agents/check_mk_agent.linux
  '';

  installPhase =
    let
      path = stdenv.lib.makeBinPath ([
        coreutils
        zfs
        gnused
        gnugrep
        ethtool
        postfix
        lvm2
      ] ++ extraPackages);
    in
    ''
      install -D -m744 agents/check_mk_agent.linux $out/bin/check_mk_agent
      wrapProgram "$out/bin/check_mk_agent" \
        --prefix PATH ":" ${path}
    '';

  meta = with stdenv.lib; {
    description = "Agent to send information to a Check_MK server";
    homepage = "https://checkmk.com/";
    license = licenses.gpl2;
    platforms = platforms.unix;
  };
}
