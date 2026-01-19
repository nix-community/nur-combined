{
    bash,
	mesa,
	mesa-gl-headers,
	openssl,
	stdenv,
	lib,
	symlinkJoin,
	makeDesktopItem,
	writeShellScriptBin,
	icu,
	libgcc,
	pkg-config,
	pulseaudio,
	freetype,
	dotnetCorePackages,
	libGL,
	libxrandr,
	mono,
	SDL2,
	libx11,
#sdv-exec-location ? "$HOME/Games/Stardew Valley/game/Stardew Valley",
	sdv-exec-location ? "/mnt/m35-mako/Stardew Valley/game/StardewValley",
}:
let
dotnetPkg = (with dotnetCorePackages; combinePackages [ sdk_10_0 ]);
deps = [ icu icu.dev openssl dotnetPkg SDL2 mono freetype libxrandr libxrandr.dev libx11 libx11.dev freetype.dev pkg-config SDL2.dev libGL libGL.dev libgcc libgcc.lib bash bash.dev mesa mesa-gl-headers stdenv.cc.libc_bin pulseaudio pulseaudio.dev ];

script = writeShellScriptBin "stardew-valley" ''
export NIX_LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${lib.makeLibraryPath ([ stdenv.cc.cc ] ++ deps)}
export NIX_LD=${stdenv.cc.libc_bin}/bin/ld.so
"${sdv-exec-location}"
'';

desktopItems = [
    (makeDesktopItem {
     name = "stardew-valley";
     desktopName = "Stardew Valley";
     icon = "stardew-valley";
     exec = "${script}/bin/stardew-valley";
     categories = ["Game"];
     })
];

in
symlinkJoin {
    name = "stardew-valley";
    paths = [
	desktopItems
	    script
    ] ++ deps;
}
