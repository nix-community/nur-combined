{
    inputs,
    timestampToDate,
    lib,
    stdenv,
    meson,
    ninja,
    pkg-config,
    dbus,
    systemdLibs,
    glib,
}:

stdenv.mkDerivation {
    pname = "org.freedesktop.FileManager1.common";
    version = timestampToDate inputs._meta.filemanager1-common.lastModified;

    src = inputs.filemanager1-common;

    nativeBuildInputs = [
        meson
        ninja
        pkg-config
    ];

    buildInputs = [
        dbus
        systemdLibs
        glib
    ];

    mesonFlags = [
        "-Dsystemd=enabled"
    ];

    # Patch wrapper scripts to use Nix store paths
    postPatch = ''
        for wrapper in config/*-wrapper.sh; do
          echo "Patching $wrapper"

          substituteInPlace "$wrapper" \
            --replace-fail "/usr/bin/" ""

          substituteInPlace "$wrapper" \
            --replace 'eval "$termcmd -- ' 'eval "$termcmd ' || true

          chmod +x "$wrapper"
        done
    '';

    meta = {
        description = "Using File Manager DBus Interface to open file manager and hover over file(s)/folder(s)";
        homepage = "https://github.com/boydaihungst/org.freedesktop.FileManager1.common";
        license = lib.licenses.mit;
    };
}
