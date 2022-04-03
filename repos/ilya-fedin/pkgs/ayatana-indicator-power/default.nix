{ lib, stdenv, fetchFromGitHub, pkg-config, cmake, cmake-extras, intltool, systemd
, glib, wrapGAppsHook, libnotify, gtk3, libayatana-common
}:

stdenv.mkDerivation rec {
  pname = "ayatana-indicator-power";
  version = "22.2.0";

  src = fetchFromGitHub {
    owner = "AyatanaIndicators";
    repo = pname;
    rev = version;
    sha256 = "sha256-uhHPrlajDmZ1RE9S1igTc44CRUFEGbQ6o+hzT5vsWJQ=";
  };

  postPatch = ''
    substituteInPlace data/CMakeLists.txt \
      --replace 'pkg_get_variable(SYSTEMD_USER_DIR systemd systemduserunitdir)' 'set(SYSTEMD_USER_DIR "''${CMAKE_INSTALL_FULL_LIBDIR}/systemd/user")' \
      --replace "/etc/xdg/autostart" "$out/etc/xdg/autostart"
  '';

  nativeBuildInputs = [ pkg-config cmake cmake-extras intltool wrapGAppsHook ];

  buildInputs = [ glib libnotify gtk3 libayatana-common systemd ];

  cmakeFlags = [ "-DGSETTINGS_LOCALINSTALL=ON" "-DGSETTINGS_COMPILE=ON" ];

  meta = with lib; {
    description = "Ayatana Indicator Power Applet";
    homepage = "https://github.com/AyatanaIndicators/${pname}";
    changelog = "https://github.com/AyatanaIndicators/${pname}/blob/${version}/ChangeLog";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [ maintainers.ilya-fedin ];
  };
}
