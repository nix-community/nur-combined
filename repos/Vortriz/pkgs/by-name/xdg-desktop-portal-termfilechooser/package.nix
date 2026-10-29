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
    version = "unstable-2026-10-24";

    src = fetchFromGitHub {
        owner = "hunkyburrito";
        repo = "xdg-desktop-portal-termfilechooser";
        rev = "ed89c164c28f353d636a8ac68c7e35ce37f882bd";
        hash = "sha256-U3Fv6Q8HYQEi8rZfGUJCEMVxZwxtpQNIAwctKWDyjZw=";
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
