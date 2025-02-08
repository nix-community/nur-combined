# Workaround for <https://github.com/NixOS/nixpkgs/issues/368061>
{hostPlatform, pyglet'}: if hostPlatform.isDarwin then (pyglet'.override {
    glibc = "<dummy>";
}).overridePythonAttrs (old: {
    postPatch = builtins.replaceStrings ["<dummy>/lib/libc.dylib.6"] ["/usr/lib/libc.dylib"] (old.postPatch or "");
}) else pyglet'
