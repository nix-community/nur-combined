# Workaround for <https://github.com/NixOS/nixpkgs/issues/368061>
{stdenv, pyglet'}: if stdenv.hostPlatform.isDarwin then (pyglet'.override {
    glibc = "<dummy>";
}).overridePythonAttrs (old: {
    postPatch = builtins.replaceStrings ["<dummy>/lib/libc.dylib.6"] ["/usr/lib/libc.dylib"] (old.postPatch or "");
    meta = removeAttrs old.meta ["platforms"];
}) else pyglet'
