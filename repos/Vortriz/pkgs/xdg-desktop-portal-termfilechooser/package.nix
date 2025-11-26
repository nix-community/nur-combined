{
    lib,
    stdenv,
    fetchFromGitHub,
    xdg-desktop-portal,
    ninja,
    meson,
    pkg-config,
    inih,
    systemd,
    scdoc,
}:
stdenv.mkDerivation {
    pname = "xdg-desktop-portal-termfilechooser";
    version = "1.2.1-unstable-2025-11-25";

    src = fetchFromGitHub {
        owner = "hunkyburrito";
        repo = "xdg-desktop-portal-termfilechooser";
        rev = "3c2a6e4bf22c910b16f6d05eee197c8fcf0a5d8c";
        fetchSubmodules = false;
        sha256 = "sha256-rjqVepUrk87OVW/wwrD3PKZf1CJs6i1nzr1xWjGKEL8=";
    };

    nativeBuildInputs = [
        meson
        ninja
        pkg-config
        scdoc
    ];

    buildInputs = [
        xdg-desktop-portal
        inih
        systemd
    ];

    mesonFlags = [ "-Dsd-bus-provider=libsystemd" ];

    meta = with lib; {
        description = "xdg-desktop-portal backend for choosing files with your favorite file chooser";
        homepage = "https://github.com/hunkyburrito/xdg-desktop-portal-termfilechooser";
        license = licenses.mit;
        platforms = platforms.linux;
        mainProgram = "xdg-desktop-portal-termfilechooser";
    };
}
