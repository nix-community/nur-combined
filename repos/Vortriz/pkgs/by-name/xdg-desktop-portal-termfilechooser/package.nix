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
    version = "unstable-2026-06-13";

    src = fetchFromGitHub {
        owner = "hunkyburrito";
        repo = "xdg-desktop-portal-termfilechooser";
        rev = "cb8cec0b30aa6e2cc36b1b5cb34d6dc9a1face29";
        hash = "sha256-zk/zUbq+fa977wuT/yuJ+bBawuTXKVJwLj2G8ITjMfU=";
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
