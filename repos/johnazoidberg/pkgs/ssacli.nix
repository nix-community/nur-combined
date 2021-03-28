{ stdenv, lib, fetchurl, rpmextract, autoPatchelfHook
}:
stdenv.mkDerivation rec {
  pname = "ssacli";
  # TODO: A newer version seems to be available from
  # https://support.hpe.com/hpesc/public/swd/detail?swItemId=MTX_521fc533ba8f468f9ad9db20e4
  version = "4.17-6.0";

  src = fetchurl {
    url = "https://downloads.linux.hpe.com/SDR/repo/mcp/centos/8/x86_64/current/${pname}-${version}.x86_64.rpm";
    sha256 = "11qfl48bmaszqi4wy2mnpa4f9qhpbh5av36q44nxq7d5carh6i44";
  };

  nativeBuildInputs = [
    rpmextract autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    rpmextract $src
  '';

  # TODO: Use install instead of copy
  installPhase = ''
    runHook preInstall

    cp -r usr $out
    cp -r opt $out/

    runHook postInstall
  '';

  # TODO: Fixup manpage not to refer to /opt
  postFixup = ''
    substituteInPlace $out/bin/ssacli --replace "/opt" "$out/opt"
    substituteInPlace $out/bin/ssascripting --replace "/opt" "$out/opt"
  '';

  meta = {
    description = "Command line disk configuration utility for HPE Smart RAID and Smart HBA controllers";
    maintainers = with lib.maintainers; [ johnazoidberg ];
    license = lib.licenses.unfree;
    homepage = "https://downloads.linux.hpe.com/SDR/project/mcp/";
    platforms = [ "x86_64-linux" ];
  };
}
