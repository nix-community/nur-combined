{ lib, stdenv, fetchFromGitHub, pkg-config, cmake, cmake-extras, intltool, glib }:

stdenv.mkDerivation rec {
  pname = "libayatana-common";
  version = "0.9.7";

  src = fetchFromGitHub {
    owner = "AyatanaIndicators";
    repo = pname;
    rev = version;
    sha256 = "sha256-bBk3NGe2/AHgcQJezrhw01CuidDTKyVMW5qoSriQxj8=";
  };

  nativeBuildInputs = [ pkg-config cmake cmake-extras intltool ];

  buildInputs = [ glib ];

  cmakeFlags = [ "-DGSETTINGS_LOCALINSTALL=ON" "-DGSETTINGS_COMPILE=ON" ];

  meta = with lib; {
    description = "Shared Library for common functions required by the Ayatana System Indicators";
    homepage = "https://github.com/AyatanaIndicators/${pname}";
    changelog = "https://github.com/AyatanaIndicators/${pname}/blob/${version}/ChangeLog";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [ maintainers.ilya-fedin ];
  };
}
