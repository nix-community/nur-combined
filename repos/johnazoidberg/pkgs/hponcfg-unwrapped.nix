{ stdenv, lib, fetchurl, rpmextract, autoPatchelfHook
}:
stdenv.mkDerivation rec {
  pname = "hponcfg";
  version = "5.6.0-0";

  src = fetchurl {
    url = "https://downloads.linux.hpe.com/SDR/repo/mcp/centos/8/x86_64/current/${pname}-${version}.x86_64.rpm";
    sha256 = "0cjzslclli79z2vpah7ksckpi7as1ay65qi5b5ds612mp95d1c0w";
  };

  nativeBuildInputs = [
    rpmextract autoPatchelfHook
  ];

  unpackPhase = ''
    rpmextract $src
  '';

  # TODO: Use install instead of cp
  installPhase = ''
    runHook preInstall

    cp -r usr $out
    cp -r sbin $out/

    runHook postInstall
  '';

  postFixup = let
    # hponcfg shells out to:
    # $ /sbin/ldconfig -p | awk '{ print $NF }' | grep libssl.so | sort -t. -k 3 -g -r | head -n +%d
    #
    # ldconfig -p doesn't work on NixOS, so we have to replace it.
    # Both must be the same length to not mess with the offsets in the binary.
    oldFindSslCommandPrefix = "/sbin/ldconfig -p | awk";
    newFindSslCommandPrefix = "echo /usr/lib/libssl.so";
  in ''
    cp $out/lib64/libhponcfg64.so $out/lib64/libhponcfg.so

    sed -i 's@${oldFindSslCommandPrefix}@${newFindSslCommandPrefix}@g' $out/bin/hponcfg
  '';

  meta = {
    description = "HPE RILOE II/iLO online configuration utility";
    maintainers = with lib.maintainers; [ johnazoidberg ];
    license = lib.licenses.unfree;
    homepage = "https://downloads.linux.hpe.com/SDR/project/mcp/";
    platforms = [ "x86_64-linux" ];
  };
}
