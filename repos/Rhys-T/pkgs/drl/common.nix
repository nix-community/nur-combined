{lib, maintainers, stdenvNoCC}: {
    meta = {
        description = "Roguelike game based on the FPS Doom";
        longDescription = ''
            DRL (D**m, the Roguelike) is a fast and furious coffee-break Roguelike game, that is heavily inspired by the popular FPS game Doom by ID Software.
        '';
        homepage = "https://drl.chaosforge.org/";
        license = with lib.licenses; [
            # Code
            gpl2Only
            # Artwork
            # Music (according to <https://simonvolpert.com/drla/>)
            cc-by-sa-40
        ];
        platforms = lib.platforms.linux ++ lib.platforms.darwin;
        maintainers = [maintainers.Rhys-T];
        # makewad tool is run at build-time, and I haven't gotten around to separating it out yet.
        broken = with stdenvNoCC; !(buildPlatform.canExecute hostPlatform);
    };
}