let
    options = import ./options.nix {};
    minivmacFunc = {
        version,
        src,
        minivmac ? null, execName ? "minivmac",
        applyMacDataPathPatch ? false,
        callPackage, lib, runCommandLocal, makeBinaryWrapper, stdenv, darwin ? null, Cocoa ? darwin.apple_sdk.frameworks.Cocoa, xorg, alsaLib, maintainers, ...
    }@args:
        let options = callPackage ./options.nix { }; in
        if execName != "minivmac" then
            callPackage ./renamed.nix {
                minivmac = minivmac.override (removeAttrs args ["execName"]);
                pname = execName;
            }
        else
        let
            inherit (stdenv) hostPlatform;
            inherit (hostPlatform) isDarwin isLinux;
            targetCodes = {
                x86_64-linux = "lx64";
                i686-linux = "lx86";
                x86_64-darwin = "mc64";
            } // lib.optionalAttrs ((builtins.compareVersions "37a" version) <= 0) {
                aarch64-darwin = "mcar";
            };
            minivmacOptions = options.buildOptionsFrom args;
            targetCode = minivmacOptions.targetCode or targetCodes.${hostPlatform.system} or (throw ''
                Platform ${hostPlatform.system} is not currently supported by this derivation.
                If this platform is listed on one of:
                - https://www.gryphel.com/c/minivmac/options.html#option_t
                - https://www.gryphel.com/c/minivmac/develop.html#option_t
                then you can try overriding the "targetCode" option and passing the correct code there.
            '');
        in
        assert lib.assertMsg (!(applyMacDataPathPatch && !isDarwin)) "patch only valid on Mac";
        let
            minivmac = stdenv.mkDerivation {
                pname = "minivmac";
                inherit version src;
                patches = lib.optionals applyMacDataPathPatch [ ./mac-data-path-from-env.patch ];
                postPatch = lib.optionalString hostPlatform.isLinux ''
                substituteInPlace src/SGLUALSA.h --replace-fail '"libasound.so.2"' "\"${alsaLib.out}/lib/libasound.so.2\""
                '' + ''
                for file in setup/*.i; do
                    sed -E -i '
                        /LOCALPROC WriteCompileCExec/ {
                            n
                            s/$/ WriteCStrToDestFile("@CC@"); return; /
                        }
                        ${lib.optionalString hostPlatform.isDarwin ''
                            /-mmacosx-version-min/s@^@//@
                        ''}
                    ' "$file"; substituteInPlace "$file" --replace-quiet '@CC@' "$CC"
                done 2>/dev/null
                if strip --version 2>&1 | grep -q llvm-strip; then
                    for file in setup/*.i; do sed -i 's/"strip -u -r"/"true strip -u -r"/g' "$file"; done 2>/dev/null
                fi
                '';
                configurePhase = ''
                cc -o setup_t setup/tool.c
                ./setup_t -t ${targetCode} ${minivmacOptions} ${lib.optionalString (hostPlatform.isDarwin && (builtins.compareVersions "37a" version) <= 0) "-cl"} > setup.sh
                bash setup.sh
                '';
                # Mini vMac gets stuck in the background if I run it from a symlink in bin - use a wrapper instead
                nativeBuildInputs = lib.optionals hostPlatform.isDarwin [ makeBinaryWrapper ];
                buildInputs = lib.optionals hostPlatform.isLinux [ xorg.libX11 ] ++ lib.optionals hostPlatform.isDarwin [ Cocoa ];
                installPhase = if stdenv.isLinux then ''
                mkdir -p $out/bin
                cp minivmac $out/bin/minivmac
                '' else ''
                mkdir -p $out/Applications $out/bin
                cp -r minivmac.app $out/Applications/minivmac.app
                makeWrapper $out/Applications/minivmac.app/Contents/MacOS/minivmac $out/bin/minivmac
                '';
                meta = {
                    description = "Miniature early Macintosh emulator";
                    longDescription = ''
                        The Mini vMac emulator collection allows modern computers to run software made for early Macintosh computers, the computers that Apple sold from 1984 to 1996 based upon Motorola's 680x0 microprocessors. Mini vMac is part of the [Gryphel Project](https://www.gryphel.com/).
                    '';
                    homepage = "https://www.gryphel.com/c/minivmac/";
                    changelog = "https://www.gryphel.com/c/minivmac/change/v${lib.versions.major version}.html";
                    license = lib.licenses.gpl2Only;
                    branch = lib.versions.major version;
                    platforms = builtins.attrNames targetCodes;
                    maintainers = [ maintainers.Rhys-T ];
                    mainProgram = execName;
                };
            };
        in minivmac
    ;
in minivmacFunc
