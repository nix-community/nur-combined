{ stdenv, lib, fetchurl, rpmextract, autoPatchelfHook
}:
stdenv.mkDerivation rec {
  pname = "ssacli";
  version = "5.10-44.0";

  src = fetchurl {
    url = "https://downloads.linux.hpe.com/SDR/repo/mcp/centos/8/x86_64/current/${pname}-${version}.x86_64.rpm";
    sha256 = "sha256:0i6q4pzs5h3p4b6f5gkchxzm23fagw4c5ba4s3lpwc7h1835wzl5";
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
