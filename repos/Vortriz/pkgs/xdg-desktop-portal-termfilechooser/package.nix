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
    version = "1.2.1-unstable-2025-11-11";

    src = fetchFromGitHub {
        owner = "hunkyburrito";
        repo = "xdg-desktop-portal-termfilechooser";
        rev = "8697babc62c89e79ed6b17a4edfde88e7d81ecaf";
        fetchSubmodules = false;
        sha256 = "sha256-/Ow8NbcXGlS3CVq2/Ndqg/Fh79bl0DqooLbTUWr3r/k=";
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
