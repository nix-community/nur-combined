# taken from the now dropped NixOS package libfprint-focaltech-2808-a658
{
    sources,
    stdenv,
    lib,
    rpm,
    cpio,
    glib,
    gusb,
    pixman,
    libgudev,
    nss,
    libfprint,
    cairo,
    pkg-config,
    autoPatchelfHook,
    makePkgconfigItem,
    copyPkgconfigItems,
}: let
    # The provided `.so`'s name in the binary package we fetch and unpack
    libso = "libfprint-2.so.2.0.0";
    inherit (sources.libfprint-focaltech-2808-a658-alt) src pname version;
in
    stdenv.mkDerivation rec {
        # https://gitlab.freedesktop.org/libfprint/libfprint/-/merge_requests/413#note_2476573
        inherit pname version src;

        nativeBuildInputs = [
            rpm
            cpio
            pkg-config
            autoPatchelfHook
            copyPkgconfigItems
        ];

        buildInputs = [
            stdenv.cc.cc
            glib
            gusb
            pixman
            nss
            libgudev
            libfprint
            cairo
        ];

        unpackPhase = ''
            runHook preUnpack

            rpm2cpio $src | cpio -idmv

            runHook postUnpack
        '';

        # custom pkg-config based on libfprint's pkg-config
        pkgconfigItems = [
            (makePkgconfigItem rec {
                name = "libfprint-2";
                inherit version;
                inherit (meta) description;
                cflags = ["-I${variables.includedir}/libfprint-2"];
                libs = [
                    "-L${variables.libdir}"
                    "-lfprint-2"
                ];
                variables = rec {
                    prefix = "${placeholder "out"}";
                    includedir = "${prefix}/include";
                    libdir = "${prefix}/lib";
                };
            })
        ];

        installPhase = ''
            runHook preInstall

            install -Dm444 usr/lib64/${libso} -t $out/lib

            # create this symlink as it was there in libfprint
            ln -s -T $out/lib/${libso} $out/lib/libfprint-2.so
            ln -s -T $out/lib/${libso} $out/lib/libfprint-2.so.2

            # get files from libfprint required to build the package
            cp -r ${libfprint}/lib/girepository-1.0 $out/lib
            cp -r ${libfprint}/include $out

            runHook postInstall
        '';

        meta = {
            description = "Focaltech Fingerprint driver for focaltech 0x2808:0xa658";
            homepage = "https://github.com/ftfpteams/RTS5811-FT9366-fingerprint-linux-driver-with-VID-2808-and-PID-a658";
            license = lib.licenses.unfree;
            platforms = ["x86_64-linux"];
            sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        };
    }
