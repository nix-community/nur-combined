{ stdenv, lib, fetchFromGitHub, fetchurl, cmake, pkg-config, kdePackages, qt6
, glib, polkit, lingmoui, lingmo-core, lib_lingmo }:

let
  # polkit-qt-1 0.200.0 is not in the pinned nixpkgs, build it locally.
  # This version supports Qt6 via -DQT_MAJOR_VERSION=6 (v0.114.0 only supports Qt5).
  polkit-qt-1 = stdenv.mkDerivation {
    pname = "polkit-qt-1";
    version = "0.200.0";
    src = fetchurl {
      url = "https://download.kde.org/stable/polkit-qt-1/polkit-qt-1-0.200.0.tar.xz";
      hash = "sha256-XTthHAYtK3apN1C7EMkHv9IdH/CNChXcLPY+J44Wd/s=";
    };
    nativeBuildInputs = [ cmake pkg-config ];
    buildInputs = [ qt6.qtbase glib polkit ];
    # Use relative install dirs so .pc file templates (${prefix}/@var@) don't produce // paths
    cmakeFlags = [
      "-DQT_MAJOR_VERSION=6"
      "-DCMAKE_INSTALL_LIBDIR=lib"
      "-DCMAKE_INSTALL_INCLUDEDIR=include"
    ];
    dontWrapQtApps = true;
    meta = {
      description = "Qt6 wrapper around PolKit";
      platforms = lib.platforms.linux;
    };
  };
in

stdenv.mkDerivation rec {
  pname = "lingmo-polkit-agent";
  version = "main";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-polkit-agent";
    rev = "93b81233a4f2816aec0d8d97345f285835906cd5";
    hash = "sha256-CJsq9/koNCtGcsuk6IgtAbOf5VS3dDb7GoMqLLNHs80=";
  };

  postPatch = ''
    # 1. Replace Dtk6-dependent source files with Qt6-only equivalents
    cp ${./patched-main.cpp} main.cpp
    cp ${./patched-AuthDialog.h} AuthDialog.h
    cp ${./patched-AuthDialog.cpp} AuthDialog.cpp
    cp ${./patched-accessible.h} accessible.h

    # 2. Generate DBus interface files (replacing dtk_add_dbus_interfaces macros)
    qdbusxml2cpp -p accounts1interface.h:accounts1interface.cpp \
      dbus/org.deepin.dde.Accounts1.xml
    qdbusxml2cpp -p accounts1userinterface.h:accounts1userinterface.cpp \
      dbus/org.deepin.dde.Accounts1.User.xml

    # 3. Fix namespace collision between the two qdbusxml2cpp outputs:
    #    accounts1interface.h generates 'using Accounts1 = ::OrgDeepinDdeAccounts1Interface'
    #    accounts1userinterface.h generates 'namespace Accounts1 { class User }'
    #    They conflict in 'org::deepin::dde'. Remove the using alias and use the full class name.
    sed -i '/using Accounts1 =/d' accounts1interface.h
    sed -i 's|using AccountsDBus = org::deepin::dde::Accounts1|using AccountsDBus = ::OrgDeepinDdeAccounts1Interface|' usersmanager.h
    #    Also fix the lowercase-vs-capital mismatch:
    #    qdbusxml2cpp generates namespace ::Accounts1::User (capital A)
    #    but the original uses lower-case ::accounts1::User
    sed -i 's|org::deepin::dde::accounts1::User|org::deepin::dde::Accounts1::User|g' usersmanager.h

    # 4. Remove FullNameChanged signal connection in usersmanager.cpp.
    #    Dtk's dtk_add_dbus_interface macro auto-generates property change signals
    #    (e.g. FullNameChanged for the FullName property), but plain qdbusxml2cpp
    #    does not. For a polkit agent (short-lived process), the initial fullName()
    #    cached in userAdded() is sufficient — no need for real-time updates.
    sed -i '/FullNameChanged/,+2d' usersmanager.cpp

    # 5. Patch CMakeLists.txt — remove Dtk6, DDEShell, Dde::Shell references.
    #    The upstream cmake uses the variable $DTK_VERSION_MAJOR so
    #    match on the prefix Dtk (in find_package) and Dtk.*:: (in lib refs).
    sed -i '/find_package(Dtk/d' CMakeLists.txt
    sed -i '/find_package(DDEShell/d' CMakeLists.txt
    sed -i '/dtk_add_dbus_interface/d' CMakeLists.txt
    sed -i '/Dtk.*::Core/d' CMakeLists.txt
    sed -i '/Dtk.*::Widget/d' CMakeLists.txt
    sed -i '/Dde::Shell/d' CMakeLists.txt

    # 5. Fix hardcoded /usr/ and /etc/ paths
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION "/usr/|DESTINATION "|g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION "/etc/|DESTINATION "etc/|g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /usr/|DESTINATION |g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /etc/|DESTINATION etc/|g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /etc|DESTINATION etc|g' {} +
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
    qt6.qttools
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtsvg
    qt6.qtwayland
    kdePackages.kcoreaddons
    kdePackages.kwindowsystem
    polkit-qt-1
    lingmoui
    lingmo-core
    lib_lingmo
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=20"
  ];

  # polkit agent must run setuid-aware; the binary goes to lib/polkit-1-dde/
  # which is non-standard, so let cmake handle installation paths
  dontWrapQtApps = true;

  meta = with lib; {
    description = "LingmoOS PolicyKit authentication agent";
    homepage = "https://github.com/LingmoOS/lingmo-polkit-agent";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
