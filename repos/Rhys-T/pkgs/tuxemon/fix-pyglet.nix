# Workaround for <https://github.com/NixOS/nixpkgs/issues/368061>
{stdenv, pyglet'}: if stdenv.hostPlatform.isDarwin then (pyglet'.override {
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
