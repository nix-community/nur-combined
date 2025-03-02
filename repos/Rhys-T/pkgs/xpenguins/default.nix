{
    callPackage, lib,
    makeBinaryWrapper, symlinkJoin,
    _xpenguins-unwrapped ? callPackage ./unwrapped.nix {}, themes ? [],
}: let unwrapped = _xpenguins-unwrapped; in if themes == [] then unwrapped else symlinkJoin {
    pname = "${unwrapped.pname}-with-themes";
    inherit (unwrapped) version;
    paths = [unwrapped] ++ themes;
    nativeBuildInputs = [makeBinaryWrapper];
    postBuild = ''
        wrapProgram "$out/bin/xpenguins" --add-flags "-c $out/share/xpenguins"
    '';
    meta = unwrapped.meta // {
        license = lib.unique (lib.concatMap (p: lib.toList (p.meta.license or [])) ([unwrapped] ++ themes));
    };
}
