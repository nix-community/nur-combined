{
    pkgs ? import <nixpkgs> {},
    path ? null,
    ...
}@args: (import (pkgs.path + "/maintainers/scripts/update.nix") (removeAttrs args ["pkgs" "path"] // {
    path = "Rhys-T" + pkgs.lib.optionalString (path != null) ".${path}";
    include-overlays = [(self: super: {
        Rhys-T = import ./. { pkgs = self; };
    })];
})).overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ (with pkgs; lib.optional stdenv.hostPlatform.isDarwin [git]);
    shellHook = let
        parts = builtins.match "^(.* )([^ ]+-packages\\.json)(.*)$" old.shellHook;
        before = builtins.elemAt parts 0;
        packagesJson = builtins.elemAt parts 1;
        after = builtins.elemAt parts 2;
        newHook = ''${before}<(${pkgs.lib.getExe pkgs.jq} '.[].attrPath |= sub("^Rhys-T\\."; "")' ${packagesJson})${after}'';
        
        # With NixOS/Nixpkgs#425068, update.py now runs each updateScript through Nixpkgs' shell.nix.
        # Unfortunately, with the way I'm (ab)using update.nix, it ends up looking for shell.nix in _my_ repository.
        # So I now have to inject a wrapper script that patches the right path in.
        needsShellNixPatch = pkgs.lib.hasInfix "/shell.nix" (builtins.readFile (pkgs.path + "/maintainers/scripts/update.py"));
        parts' = builtins.match "^(.* )([^ ]+update\\.py)(.*)$" newHook;
        before' = builtins.elemAt parts' 0;
        updatePy = builtins.elemAt parts' 1;
        after' = builtins.elemAt parts' 2;
        newHook' = if needsShellNixPatch then ''${before'}${./update-wrapper.py} ${toString pkgs.path} ${updatePy}${after'}'' else newHook;
    in pkgs.lib.addContextFrom old.shellHook newHook';
})
