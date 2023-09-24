{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  autoreconfHook,
}:
stdenv.mkDerivation rec {
  pname = "netcalc";
  version = "2.1.6";

  src = fetchFromGitHub {
    owner = "troglobit";
    repo = "netcalc";
    rev = "v${version}";
    hash = "sha256-PpAMsulXg67Wjttp0gInjychxouJ99he0Pc/pKbg3XY=";
  };

  nativeBuildInputs = [pkg-config autoreconfHook];

  meta = with lib; {
    description = "netcalc is a clone of sipcalc using the output format of ipcalc";
    homepage = "https://github.com/troglobit/netcalc";
    license = licenses.bsd3;
    platforms = platforms.unix;
    maintainers = with maintainers; [vifino];
  };
}
