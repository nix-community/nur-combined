{
  lib,
  wineWow64Packages,
  fetchFromGitHub,
  nix-update-script,
}:

let
  version = "0.2.2-beta.2";

  src = fetchFromGitHub {
    owner = "ttv20";
    repo = "wine4office";
    tag = version;
    hash = "sha256-Tw9SdnV5zYTaSiFb2CQhqQ9MYBAdwJR/JGG0RC9OnvM=";
  };
in
# Wine 11.17 fork; the nixpkgs wow64 build already configures
# --enable-archs=x86_64,i386, which is what upstream's Office build uses.
# Overriding `version` is safe for the inherited postInstall: it closes over
# the nixpkgs wine version, so the gstreamer wrapper still gets --inherit-argv0.
wineWow64Packages.unstableFull.overrideAttrs (old: {
  pname = "wine4office";
  inherit version src;

  # Upstream's canonical build contract (tools/wine-build-env/build.sh) also
  # requires these two.
  configureFlags = (old.configureFlags or [ ]) ++ [
    "--with-gssapi"
    "--with-krb5"
  ];

  # Upstream points CPPFLAGS at its bundled UAPI headers so configure detects
  # linux/ntsync.h (NT synchronization primitives, used by Office).
  preConfigure = (old.preConfigure or "") + ''
    export CPPFLAGS="-isystem ${src}/tools/wine4office-manager/packaging/linux-uapi $CPPFLAGS"
  '';

  passthru = (old.passthru or { }) // {
    updateScript = nix-update-script { };
  };

  meta = (old.meta or { }) // {
    inherit version;
    description = "Wine fork with the compatibility fixes needed to run modern Microsoft Office on Linux";
    homepage = "https://github.com/ttv20/wine4office";
    downloadPage = "https://github.com/ttv20/wine4office/releases";
    license = lib.licenses.lgpl21Plus;
    mainProgram = "wine";
    platforms = [ "x86_64-linux" ];
  };
})
