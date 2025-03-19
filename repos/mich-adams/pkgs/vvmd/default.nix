{
  lib,
  stdenv,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  mobile-broadband-provider-info,
  gettext,
  curl,
  glib,
  dbus,
  glibmm,
  modemmanager,
  c-ares,
  libphonenumber,
  protobuf,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "vvmd";
  version = "1.0";

  src = fetchFromGitLab {
    owner = "kop316";
    repo = "vvmd";
    rev = version;
    hash = "sha256-mSY3O6qs33ymhIq5UUs5XEUta1F87n8QJLMbq6m0qWI=";
  };

  nativeBuildInputs = [
    meson
    pkg-config
    cmake
  ];

  buildInputs = [
    ninja
    mobile-broadband-provider-info
    gettext
    curl
    glib
    dbus
    glibmm
    modemmanager
    c-ares
    libphonenumber
    protobuf
  ];

  meta = with lib; {
    description = "A lower level daemon that retrieves Visual Voicemail";
    homepage = "https://gitlab.com/kop316/vvmd";
    changelog = "https://gitlab.com/kop316/vvmd/-/blob/${src.rev}/ChangeLog";
    license = licenses.gpl2;
    #maintainers = with maintainers; [ mich-adams ];
    mainProgram = "vvmd";
    platforms = platforms.linux;
  };
}
