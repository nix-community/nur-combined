# Workaround for <https://github.com/NixOS/nixpkgs/issues/368061>
# Not needed after <https://github.com/NixOS/nixpkgs/pull/418779>
{stdenv, lib, pyglet'}: let
    pr418779Merged = (lib.functionArgs pyglet'.override)?apple-sdk;
in if stdenv.hostPlatform.isDarwin && !pr418779Merged then (pyglet'.override {
    glibc = "<dummy>";
    libGL = "<dummy>";
    libGLU = "<dummy>";
}).overridePythonAttrs (old: {
    postPatch = builtins.replaceStrings [
        "<dummy>/lib/libc.dylib.6"
        "<dummy>/lib/libGL.dylib"
        "<dummy>/lib/libGLU.dylib"
    ] [
        "/usr/lib/libc.dylib"
        "/System/Library/Frameworks/OpenGL.framework/Libraries/libGL.dylib"
        "/System/Library/Frameworks/OpenGL.framework/Libraries/libGLU.dylib"
    ] (old.postPatch or "");
    meta = removeAttrs old.meta ["platforms"];
}) else pyglet'
