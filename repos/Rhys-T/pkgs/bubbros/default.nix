{
    stdenv, lib, fetchurl,
    # fetchFromGitHub, SDL2_image_2_0, darwin,
    python27, xorg,
    groff, rsync,
    maintainers
}: let
    # TODO Try to finish resurrecting PyGame 2.0.1?
    # nixpkgs' = fetchFromGitHub {
    #   owner = "NixOS";
    #   repo = "nixpkgs";
    #   rev = "55b68d31884a7ab75eb8d48c8a3a20920113bfa3";
    #   sparseCheckout = [
    #       "pkgs/development/python-modules/pygame"
    #   ];
    #   nonConeMode = true;
    #   hash = "sha256-hW069GVdCSK0brh3idxRX0SipvSCPyJMni0hXzbC8xI=";
    # };
    # pygame_2_0 = ((python27.pkgs.callPackage "${nixpkgs'}/pkgs/development/python-modules/pygame" {
    #   inherit (darwin.apple_sdk.frameworks) AppKit CoreMIDI;
    #   SDL2_image = SDL2_image_2_0;
    # }).overridePythonAttrs (old: {
    #   dontUsePytestCheck = true;
    #   NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -Wno-error=incompatible-function-pointer-types";
    # })).overrideAttrs (old: {
    #   installCheckPhase = "";
    # });
    removeKnownVulnerabilities = pkg: pkg.overrideAttrs (old: {
        meta = (old.meta or { }) // { knownVulnerabilities = [ ]; };
    });
    # We are removing `meta.knownVulnerabilities` from `python27`,
    # and setting it in `bubbros` itself.
    python27ForBubBros = (removeKnownVulnerabilities python27).override {
        # strip down that python version as much as possible
        # 'borrowed' from nixpkgs/pkgs/development/misc/resholve/default.nix
        openssl = null;
        bzip2 = null;
        readline = null;
        ncurses = null;
        gdbm = null;
        sqlite = null;
        rebuildBytecode = false;
        stripBytecode = true;
        strip2to3 = true;
        stripConfig = true;
        stripIdlelib = true;
        stripTests = true;
        enableOptimizations = false;
    };
    # .withPackages (ps: [
    #   pygame_2_0
    # ]);
in stdenv.mkDerivation (finalAttrs: let self = finalAttrs.finalPackage; in {
    pname = "bubbros";
    version = "1.6.2";
    src = fetchurl {
        url = "mirror://sourceforge/bub-n-bros/bubbros-${self.version}.tar.gz";
        hash = "sha256-CtijWcRjIHGpyFwmhLrjKqD6J4YyxJ8JLcQHjPuYWMQ=";
    };
    debian = fetchurl {
        url = "mirror://debian/pool/main/b/bubbros/bubbros_${self.version}-1.debian.tar.xz";
        hash = "sha256-SqPwFWNJF3+hbbcgApQRKugwMUvAFZk036dV9x9EjV0=";
    };
    prePatch = ''
    tar -xaf "$debian"
    patches="$(cat debian/patches/series | sed 's,^,debian/patches/,') $patches"
    '';
    postPatch = ''
        substituteInPlace display/Client.py --replace-fail 'os.readlink(LOCALDIR)' 'os.path.realpath(LOCALDIR)'
        substituteInPlace bubbob/bb.py --replace-fail 'os.readlink(LOCALDIR)' 'os.path.realpath(LOCALDIR)'
        for file in debian/bin/*.sh; do
            substituteInPlace "$file" \
                --replace-fail '/usr/share/games/bubbros' "$out/share/bubbros" \
                --replace-quiet '/usr/games/bubbros' "$out/bin/bubbros" \
                --replace-quiet 'python' ${lib.escapeShellArg (lib.getExe' python27ForBubBros "python")}
        done
    '';
    nativeBuildInputs = [groff rsync];
    buildInputs = [python27ForBubBros xorg.libX11 xorg.libXext];
    makeFlags = ["BINDIR=$(out)/bin" "LIBDIR=$(out)/share" "MANDIR=$(out)/share/man"];
    buildFlags = ["all" "docs"];
    postBuild = ''
        pushd bubbob/images
        python buildcolors.py
        popd
    '';
    installPhase = ''
        runHook preInstall
        mkdir -p "$out"/bin "$out"/share/man/man6
        rsync -a \
            --exclude='bubbob/Makefile' \
            --exclude='bubbob/setup.py' \
            --exclude='bubbob/statesaver.c' \
            --exclude='display/Makefile' \
            --exclude='display/setup.py' \
            --exclude='display/xshm.c' \
            --exclude='bubbob/doc' \
            --exclude='display/windows' \
            --exclude='**/CVS' \
            --exclude='**/.cvsignore' \
            --chmod=F-x \
            ./ "$out"/share/bubbros
        for file in debian/bin/*.sh; do
            fileBase="''${file##*/}"
            fileBase="''${fileBase%.sh}"
            cp "$file" "$out/bin/''${fileBase}"
            chmod +x "$out/bin/''${fileBase}"
        done
        cp doc/BubBob.py.1 "$out"/share/man/man6/bubbros.6
        cp doc/bb.py.1 "$out"/share/man/man6/bubbros-server.6
        cp doc/Client.py.1 "$out"/share/man/man6/bubbros-client.6
        runHook postInstall
    '';
    meta = {
        description = "Multiplayer clone of the famous Bubble Bobble game";
        longDescription = ''
            The objective of this game is to obtain points by destroying enemies
            (capturing them into bubbles and smashing those) and collecting items.
            It supports up to 10 players and is network-capable.
        '';
        homepage = "https://bub-n-bros.sourceforge.net/";
        knownVulnerabilities = [''
            bubbros depends on python27 (EOL) and is unmaintained.
            Avoid exposing its server or client to untrusted networks.
        ''];
        license = with lib.licenses; [mit artistic2];
        mainProgram = "bubbros";
        maintainers = [maintainers.Rhys-T];
    };
})
