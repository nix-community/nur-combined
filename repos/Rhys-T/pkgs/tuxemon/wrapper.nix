# 'Borrowed' from nixpkgs cataclysm-dda derivations
{lib, symlinkJoin, makeBinaryWrapper, unwrapped}:
unwrapped: pkgsSpec:
let mods = if lib.isFunction pkgsSpec then pkgsSpec unwrapped.pkgs else pkgsSpec; in
if builtins.length mods == 0 then unwrapped else symlinkJoin {
    pname = unwrapped.pname + "-with-mods";
    inherit (unwrapped) version;
    paths = [unwrapped] ++ mods;
    nativeBuildInputs = [makeBinaryWrapper];
    postBuild = ''
        wrapProgram "$out"/bin/tuxemon --set-default NIX_TUXEMON_DIR "$out"/share/tuxemon
    '';
}
