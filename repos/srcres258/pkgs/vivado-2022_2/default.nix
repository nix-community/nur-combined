{
    maintainers,
    stdenv,
    lib,
    bash,
    coreutils,
    writeScript,
    gnutar,
    gzip,
    requireFile,
    patchelf,
    procps,
    makeWrapper,
    ncurses,
    zlib,
    libX11,
    libXrender,
    libxcb,
    libXext,
    libXtst,
    libXi,
    libxcrypt,
    glib,
    freetype,
    gtk2,
    buildFHSEnv,
    gcc,
    ncurses5,
    glibc,
    gperftools,
    fontconfig,
    liberation_ttf,
}: let
    extractedSource = let
        name = "vivado-2022.2-extracted";
    in stdenv.mkDerivation {
        inherit name;

        src = let
            filename = "Xilinx_Unified_2022.2_1014_8888.tar.gz";
            url = "https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2022.2_1014_8888.tar.gz";
        in requireFile {
            name = filename;
            inherit url;
            sha256 = ""; # TODO
        };

        buildInputs = [ patchelf ];

        builder = writeScript "${name}-folder" ''
            #!${bash}/bin/bash
            source $stdenv/setup

            mkdir -p $out/
            tar -xvf $src --strip-components=1 -C $out/ Xilinx_Unified_2022.2_1014_8888/

            patchShebangs $out/
            patchelf --set-intepreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
                $out/tps/lnx64/jre11.0.11_9/bin/java
            sed -i -- 's|/bin/rm|rm|g' $out/xsetup
        '';
    };

    vivadoPackage = stdenv.mkDerivation {
        name = "vivado-2022.2";

        nativeBuildInputs = [ zlib ];
        buildInputs = [
            patchelf
            procps
            ncurses
            makeWrapper
        ];

        extracted = "${extractedSource}";

        builder = ./builder-2022_2.sh;
        inherit ncurses;

        libPath = lib.makeLibraryPath [
            stdenv.cc.cc
            ncurses
            zlib
            libX11
            libXrender
            libxcb
            libXext
            libXtst
            libXi
            freetype
            gtk2
            glib
            libxcrypt
            gperftools
            glibc.dev
            fontconfig
            liberation_ttf
        ];

        meta = {
            description = "Xilinx Vivado WebPack Edition";
            homepage = "https://www.xilinx.com/products/design-tools/vivado.html";
            license = lib.licenses.unfree;
            sourceProvenance = with lib.sourceTypes; [
                binaryNativeCode
                binaryBytecode
                binaryData
            ];
            maintainers = [ maintainers.srcres258 ];
            platforms = lib.platforms.linux;
        };
    };
in buildFHSEnv {
    name = "vivado";
    targetPkgs = _pkgs: [ vivadoPackage ];
    multiPkgs = pkgs: with pkgs; [
        coreutils
        gcc
        ncurses5
        zlib
        glibc.dev
        libxcrypt-legacy
    ];
    runScript = "vivado";
}

