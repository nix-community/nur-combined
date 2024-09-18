{stdenvNoCC, lib, buildDubPackage, enet, lix-game}: with import ./lib.nix { inherit stdenvNoCC lib enet; }; buildDubPackage {
    pname = "${lix-game.pname}-server";
    inherit (lix-game) version src;
    # dubLock = ./dub-lock.server.json;
    dubLock = let fullLock = lib.importJSON ./dub-lock.json; in {
        dependencies = lib.filterAttrs (name: info: builtins.elem name ["derelict-enet" "derelict-util"]) fullLock.dependencies;
    };
    buildInputs = [enet];
    postConfigure = patchEnetBindings;
    sourceRoot = "source/src/server";
    postUnpack = ''chmod u+w "$sourceRoot"/../..''; # need to be able to create 'bin' directory there
    installPhase = ''
    runHook preInstall
    mkdir -p "$out"/bin
    cp ../../bin/lixserv "$out"/bin
    runHook postInstall
    '';
    meta = {
        description = "${lix-game.meta.description} (standalone multiplayer server)";
        inherit (lix-game.meta) homepage maintainers;
        license = lib.licenses.cc0;
        mainProgram = "lixserv";
    };
}
