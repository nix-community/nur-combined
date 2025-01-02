# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[Current package list](https://nur.nix-community.org/repos/rhys-t/)

<!-- Remove this if you don't use github actions -->
[![Build and populate cache](https://github.com/Rhys-T/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)](https://github.com/Rhys-T/nur-packages/actions/workflows/build.yml)

<!--
Uncomment this if you use travis:

[![Build Status](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages.svg?branch=master)](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages)
-->
[![Cachix Cache](https://img.shields.io/badge/cachix-rhys--t-blue.svg)](https://rhys-t.cachix.org)

## Package-specific notes

### `drl`

DRL (formerly DoomRL) expects to run with the game directory as its working directory, containing both the read-only game data and mutable state. Obviously that doesn't work very well with Nix, so I'm using a similar approach to [the `sdlpop` derivation](https://github.com/NixOS/nixpkgs/blob/master/pkgs/games/sdlpop/default.nix): `drl` is actually a wrapper script that links/copies the game data into `${XDG_DATA_HOME:-$HOME/.local/share}/drl` as appropriate, then runs the game from there. It won't replace any file/directory there that isn't a symlink into the Nix store, so you can always override any of the files you need to.

### `hbmame`

Takes the upstream `mame` derivation to base itself off of as an argument. If you want to override dependencies and such, you'll currently need to override them on `mame`, then override `mame` on `hbmame`:

```nix
hbmame.override (old: {
    mame = old.mame.override {
        # ...
    };
})
```

By default, this is based on the `mame` derivation from this repo, which also includes fixes to build on macOS/Darwin. There's also an `hbmame-metal` based on `mame-metal` - see [the `mame` notes](#mame) below for more details.

### `hfsutils`

`hfsutils-tk` is the variant built with Tcl/Tk, which includes the `hfs`, `hfssh`, and `xhfs` commands. (I don't currently have one with Tcl only.)

### `lix-game`

Upstream is just called [Lix](https://www.lixgame.com/). I had originally written this package as an overlay, and called it `lix-game` to distinguish it from the Nix fork also called Lix. ([`lix-game` is the name Repology uses for it.](https://repology.org/project/lix-game/versions)) I have not yet changed the executable name, though - it's still just `lix`.

The game consists of several derivations that are somewhat interdependent (the game engine, the assets, the music, and the wrapper that puts it all together, as well as a standalone multiplayer server). To simplify the code and put all the configuration in one place, I've implemented it as a package set, or scope. To change the settings, instead of the base `lix-game` package, install something like this:
```nix
(lix-game-packages.overrideScope (self: super: {
    # Default values are shown here
    
    # Workarounds for SimonN/LixD#431 - see below
    convertImagesToTrueColor = true; # but only if building for macOS
    disableNativeImageLoader = false; # becomes true if previous option is disabled on macOS
    
    # SimonN/LixD#128 - see below
    useHighResTitleScreen = false;
    
    # self-explanatory
    includeMusic = true;
})).game
```

#### SimonN/LixD#431 - Magic pink won't become transparent on macOS

On macOS, upstream is affected by a [bug](https://github.com/SimonN/LixD/issues/431) which keeps it from properly substituting certain colors, resulting in large pink blocks where transparent areas should be (among other issues). This package applies a workaround, converting all the game's images to 32-bit true-color to avoid triggering the bug.

However, as far as I know there's no guarantee that NSImage will keep treating true-color images the same way in future macOS versions, meaning this workaround could break eventually - and it doesn't do anything for custom images installed in `${XDG_DATA_HOME:-$HOME/.local/share}/lix`.

Therefore, I also have an alternative workaround implemented. If you set `convertImagesToTrueColor` to `false` (or just use `lix-game-libpng`), Lix will instead be linked against a custom build of Allegro 5 which has the macOS native image loader disabled, and instead uses the same `libpng`-based method as on Linux and Windows, avoiding the bug. To prevent this as well (for instance, to test out the bug's behavior on a given version of macOS), additionally set `disableNativeImageLoader` to `false` (or use `lix-game-issue-431`).

You can also set `disableNativeImageLoader` to `"CIImage"` (or use `lix-game-CIImage`) to test out @pedro-w's [CIImage-based loader](https://github.com/liballeg/allegro5/issues/1531#issuecomment-1950198051).

#### SimonN/LixD#128 - NaOH's title screen, include hi-res instead of 640x480

There is a higher-resolution version of Lix's main menu background artwork available, but it hasn't made it into a release yet. Set this to `true` to use it.

### `mame`

The `mame` derivation in nixpkgs is currently broken on macOS. By default, nixpkgs tries to target a minimum macOS version of 10.12, and MAME requires features from newer systems. I can get it to build for macOS 10.15+ by disabling the Metal renderer (`mame`), or for macOS 11 with the Metal renderer enabled (`mame-metal`). On other platforms, these _should_ both just become the normal MAME package as-is.

**Note**: Recent versions of Nixpkgs have bumped the default minimum macOS to 11.3. If you're using those versions, `mame` will be the same derivation as `mame-metal`.

(Meanwhile, `mame` also depends on `papirus-icon-theme`, which is marked Linux-only for reasons. So I'm cheating and extracting the one icon it actually needs as its own derivation on non-Linux systems.)

### `minivmac`

I've made several of the [compile-time options](https://www.gryphel.com/c/minivmac/options.html) for Mini vMac available through `minivmac.override { ... }`. Until I can document this properly, look for the `optProc` block in `pkgs/minivmac/options.nix` to see what's available. For anything I haven't covered, you can override `rawOptions` with a string to add to the end of the `./setup_t` command.

#### Examples

```nix
minivmac.override {
    pname = "minivmac-se"; # optional - default name will be in this format
    macModel = "SE";
}
```

```nix
minivmac37.override {
    pname = "minivmac-for-atalk-games";
    macModel = "II";
    resolution = "800x600";
    localtalk = true;
    localtalkOver = "udp";
}
```

### `pce`

The current release version (0.2.2) of the upstream PCE package includes unfree ROM images for several of the computers it emulates. By default, this derivation will use a tarball hosted in this repo's `distfiles` branch which has had these removed. If you want to install from the upstream tarball, use the `pce-with-unfree-roms` package.

However, that release is several years out of date at this point. You're probably better off using `pce-snapshot`, which uses a much more recent development snapshot that has already removed the ROMs.

Normally, one of the `path` entries in a PCE config file will point to e.g. `/usr/share/pce/macplus` so that the 'ROM extensions' that make certain features work can be found. To avoid having to update this line in your config file every time PCE's store path changes (or point it at your `~/.nix-profile`, which only occurred to me as I was typing this 🤦), I've included a patch so that you can say e.g. `path = "$PCE_DIR_DATA/pce/macplus"` and have it do the right thing. (This only works for `path`, not any other settings.)

By default, this derivation uses the prebuilt extension ROMs that are included with the source. To rebuild the extension ROMs from source instead, do:
```nix
pce.override {
    buildExtensionROMs = true;
}
```
Note that this will probably have to build an `m68k-elf` cross toolchain, which may take a while.
