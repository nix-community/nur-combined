let
    options = import ./options.nix {};
    minivmacFunc = {
        pname ? let
            model = args.macModel or args.macType or "Plus";
        in "minivmac" + lib.optionalString (model != "Plus") "-${lib.toLower model}",
        version,
        src,
        applyMacDataPathPatch ? false,
        callPackage, lib, runCommandLocal, makeBinaryWrapper, stdenv, darwin ? null, Cocoa ? darwin.apple_sdk.frameworks.Cocoa, xorg, alsaLib, maintainers, ...
    }@args:
        let
            options = callPackage ./options.nix { };
            isAtLeast37 = (builtins.compareVersions "37a" version) <= 0;
            inherit (stdenv) hostPlatform;
            inherit (hostPlatform) isDarwin isLinux;
            targetCodes = {
                x86_64-linux = "lx64";
                i686-linux = "lx86";
                x86_64-darwin = "mc64";
            } // lib.optionalAttrs isAtLeast37 {
                aarch64-darwin = "mcar";
            };
            argsPlusDefaults = options.defaultOptions // args;
            # Until 37.x, these two options need to be patched into setup/CNFGDLFT.i instead
            argsForOptions = removeAttrs argsPlusDefaults (lib.optionals (!isAtLeast37) ["maintainer" "homepage"]);
            
            inherit (argsPlusDefaults) maintainer homepage;
            minivmacOptions = options.buildOptionsFrom argsForOptions;
            targetCode = minivmacOptions.targetCode or targetCodes.${hostPlatform.system} or (throw ''
                Platform ${hostPlatform.system} is not currently supported by this derivation.
                If this platform is listed on one of:
                - https://www.gryphel.com/c/minivmac/options.html#option_t
                - https://www.gryphel.com/c/minivmac/develop.html#option_t
                then you can try overriding the "targetCode" option and passing the correct code there.
            '');
        in
        assert lib.assertMsg (!(applyMacDataPathPatch && !isDarwin)) "patch only valid on Mac";
        stdenv.mkDerivation (finalAttrs: {
            inherit pname version src;
            patches = lib.optionals applyMacDataPathPatch [ ./mac-data-path-from-env.patch ];
            postPatch = lib.optionalString (!isAtLeast37 && (maintainer != null || homepage != null)) ''
            substituteInPlace setup/CNFGDLFT.i ${
                lib.optionalString (maintainer != null) ''--replace-fail '#define kMaintainerName "unknown"' '#define kMaintainerName "'${lib.escapeShellArg maintainer}\"''
            } ${
                lib.optionalString (homepage != null) ''--replace-fail '#define kStrHomePage "(unknown)"' '#define kStrHomePage "'${lib.escapeShellArg homepage}\"''
            }
            '' + lib.optionalString hostPlatform.isLinux ''
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
            ./setup_t -t ${targetCode} ${minivmacOptions} ${lib.optionalString (hostPlatform.isDarwin && isAtLeast37) "-cl"} > setup.sh
            bash setup.sh
            '';
            # Mini vMac gets stuck in the background if I run it from a symlink in bin - use a wrapper instead
            nativeBuildInputs = lib.optionals hostPlatform.isDarwin [ makeBinaryWrapper ];
            buildInputs = lib.optionals hostPlatform.isLinux [ xorg.libX11 ] ++ lib.optionals hostPlatform.isDarwin [ Cocoa ];
            installPhase = if stdenv.isLinux then ''
            mkdir -p "$out/bin"
            cp minivmac "$out/bin/$pname"
            '' else ''
            mkdir -p "$out/Applications" "$out/bin"
            cp -r "minivmac.app" "$out/Applications/$pname.app"
            makeWrapper "$out/Applications/$pname.app/Contents/MacOS/minivmac" "$out/bin/$pname"
            '';
            meta = {
                description = "Miniature early Macintosh emulator (Macintosh ${args.macModel or args.macType or "Plus"})";
                longDescription = ''
                    The Mini vMac emulator collection allows modern computers to run software made for early Macintosh computers, the computers that Apple sold from 1984 to 1996 based upon Motorola's 680x0 microprocessors. Mini vMac is part of the [Gryphel Project](https://www.gryphel.com/).
                '';
                homepage = "https://www.gryphel.com/c/minivmac/";
                changelog = "https://www.gryphel.com/c/minivmac/change/v${lib.versions.major version}.html";
                license = lib.licenses.gpl2Only;
                branch = lib.versions.major version;
                platforms = builtins.attrNames targetCodes;
                maintainers = [ maintainers.Rhys-T ];
                sourceProvenance = with lib.sourceTypes; [
                    fromSource
                    # The C code for Mini vMac contains pre-assembled machine code for:
                    # - A replacement for the floppy disk driver that gets patched into ROM
                    # - A driver ROM for the emulated video card (Macintosh II only)
                    # They're machine code for real CPUs that existed, but in the context of
                    # running them in an emulator - and because they actually _need_ to run
                    # in the emulator - 'bytecode' seems like the closest available option.
                    # Mini vMac includes the assembly code for these under extras/mydriver,
                    # along with instructions on how to build the disk driver under MPW.
                    binaryBytecode
                ];
                mainProgram = pname;
            };
        })
    ;
in minivmacFunc
