{
    pkgs ? import <nixpkgs> {},
    ...
}@args: (import (pkgs.path + "/maintainers/scripts/update.nix") (removeAttrs args ["pkgs"] // {
    path = "Rhys-T";
    include-overlays = [(self: super: {
        Rhys-T = import ./. { pkgs = self; };
    })];
})).overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ with pkgs; lib.optional stdenv.hostPlatform.isDarwin [git];
    shellHook = let
        parts = builtins.match "^(.* )([^ ]+-packages\\.json)(.*)$" old.shellHook;
        before = builtins.elemAt parts 0;
        packagesJson = builtins.elemAt parts 1;
        after = builtins.elemAt parts 2;
        newHook = ''${before}<(${pkgs.lib.getExe pkgs.jq} '.[].attrPath |= sub("^Rhys-T\\."; "")' ${packagesJson})${after}'';
    in pkgs.lib.addContextFrom old.shellHook newHook;
})
