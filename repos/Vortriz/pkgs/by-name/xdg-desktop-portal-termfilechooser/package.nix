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
    version = "unstable-2026-01-24";

    src = fetchFromGitHub {
        owner = "hunkyburrito";
        repo = "xdg-desktop-portal-termfilechooser";
        rev = "a1f5c8a89c3f3f6eeaf4998a2cf7257235ca6b01";
        hash = "sha256-UP5eHOzJT+8rETekfcf+ZW1buEROHMCIwuEXQWWmGkQ=";
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
