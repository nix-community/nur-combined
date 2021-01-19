{ stdenv
, lib
, fetchgit
}:

stdenv.mkDerivation {
  pname = "rpi-vc-log";
  version = "unstable-2020-06-11";

  src = fetchgit {
    url = "https://git.venev.name/hristo/rpi-vc-log.git";
    rev = "3d21b290e1058ed80bb64b9524d21cc0fb1c6c8e";
    sha256 = "1806nlp1xkajxhixlf82l4h8ijndsjqi6y9nxi67rsnvq1ll83jh";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp vc-log $out/bin
  '';

  meta = with lib; {
    description = "Alternative to Raspberry Pi vcdbg";
    homepage = "https://git.venev.name/hristo/rpi-vc-log/";
    license = with licenses; [ unfree ];  # not specified, assuming worst-case
    maintainers = with maintainers; [ drewrisinger ];
    platforms = [ "aarch64-linux" "armv7l-linux" ];
  };
}
