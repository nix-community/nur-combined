{ lib, stdenv, fetchFromGitHub, pkg-config, cmake, cmake-extras, intltool, systemd
, glib, libnotify, gtk3, libayatana-common, libX11, libxklavier, libxkbcommon
, accountsservice
}:

stdenv.mkDerivation rec {
  pname = "ayatana-indicator-keyboard";
  version = "22.2.2";

  src = fetchFromGitHub {
    owner = "AyatanaIndicators";
    repo = pname;
    rev = version;
    sha256 = "sha256-BJDPBjkZkIFuheJiElUxP1XXOYDFNZ3DE0YI4KyVaIw=";
  };

  postPatch = ''
    substituteInPlace data/CMakeLists.txt \
      --replace 'pkg_get_variable(SYSTEMD_USER_DIR systemd systemduserunitdir)' 'set(SYSTEMD_USER_DIR "''${CMAKE_INSTALL_FULL_LIBDIR}/systemd/user")' \
      --replace "/etc/xdg/autostart" "$out/etc/xdg/autostart"
    substituteInPlace src/service.c \
      --replace '"libayatana-keyboard' "\"$out/lib/libayatana-keyboard"
  '';

  nativeBuildInputs = [ pkg-config cmake cmake-extras intltool ];

  buildInputs = [
    glib libnotify gtk3 libayatana-common accountsservice
    libX11 libxklavier libxkbcommon systemd
    ];

  meta = with lib; {
    description = "Ayatana Indicator Keyboard Applet";
    homepage = "https://github.com/AyatanaIndicators/${pname}";
    changelog = "https://github.com/AyatanaIndicators/${pname}/blob/${version}/ChangeLog";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [ maintainers.ilya-fedin ];
  };
}
