{
    sources,
    stdenv,
    lib,
    xdg-desktop-portal,
    ninja,
    meson,
    pkg-config,
    inih,
    systemd,
    scdoc,
}: let
    inherit (sources.xdg-desktop-portal-termfilechooser) src pname date;
in
    stdenv.mkDerivation {
        inherit pname src;
        version = "unstable-${date}";

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

        mesonFlags = ["-Dsd-bus-provider=libsystemd"];

        meta = with lib; {
            description = "xdg-desktop-portal backend for choosing files with your favorite file chooser";
            homepage = "https://github.com/hunkyburrito/xdg-desktop-portal-termfilechooser";
            license = licenses.mit;
            platforms = platforms.linux;
            mainProgram = "xdg-desktop-portal-termfilechooser";
        };
    }
