{ stdenv
, lib
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
  version = "1.6.0p24";

  src = fetchurl {
    url = "https://download.checkmk.com/checkmk/${version}/check-mk-raw-${version}.cre.tar.gz";
    sha256 = "1abzjsrcl25wsknrhq7yfq76gx6f3k0mnwr8dz4wr12kqimgwifw";
  };

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    sed -i -e 's!/bin/bash!bash!' agents/check_mk_agent.linux
  '';

  installPhase =
    let
      path = lib.makeBinPath ([
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

  meta = with lib; {
    description = "Agent to send information to a Check_MK server";
    homepage = "https://checkmk.com/";
    license = licenses.gpl2;
    platforms = platforms.unix;
  };
}
