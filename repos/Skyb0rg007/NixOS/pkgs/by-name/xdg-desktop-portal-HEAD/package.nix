{
  lib,
  xdg-desktop-portal,
  fetchFromGitHub,
  fetchurl,
  dbus,
  libdex,
  replaceVars,
  wireplumber,
  nixosTests,
  nix-update-script,
}:

xdg-desktop-portal.overrideAttrs (
  finalAttrs: prevAttrs: {
    pname = "xdg-desktop-portal-HEAD";
    version = "1.22.1-unstable-2026-11-06";

    src = fetchFromGitHub {
      owner = "flatpak";
      repo = "xdg-desktop-portal";
      rev = "987607a8e5be0ee8a54462b068985fa99e522abc";
      hash = "sha256-42iX7Iy1mGx55CxTPxC62BnPdrrx1GNFtEs7hZ8+3j8=";
    };

    # nixpkgs' patches, rebased onto the src/ -> desktop-portal/ rename. Its
    # installed-tests-path.patch is dropped: the checks are disabled below.
    patches = [
      (replaceVars ./fix-icon-validation.patch { inherit (builtins) storeDir; })
      (replaceVars ./fix-sound-validation.patch { inherit (builtins) storeDir; })
    ];

    postPatch =
      builtins.replaceStrings
        [ "src/generate-method-info.py" ]
        [ "desktop-portal/generate-method-info.py" ]
        prevAttrs.postPatch;

    buildInputs = prevAttrs.buildInputs ++ [
      dbus
      wireplumber
      # Needs libdex >= 1.2. Drop this override once nixos-unstable has it.
      (libdex.overrideAttrs (
        finalLibdexAttrs: _: {
          version = "1.2.0";
          src = fetchurl {
            url = "mirror://gnome/sources/libdex/1.2/libdex-${finalLibdexAttrs.version}.tar.xz";
            hash = "sha256-afWyRMIfZAKDHDq4r4WgF3L3L7EYZ3OIQ28S8yv7Btk=";
          };
          postPatch = ''
            substituteInPlace "testsuite/meson.build" --replace-fail \
              "'test-dbus': {'extra-sources': dbus_foo, 'disable': not have_gdbus_codegen, 'is_parallel': false}," \
              "'test-dbus': {'extra-sources': dbus_foo, 'disable': true, 'is_parallel': false},"
          '';
        }
      ))
    ];

    mesonFlags = builtins.filter (flag: !lib.hasPrefix "-Dinstalled" flag) prevAttrs.mesonFlags;

    doCheck = false;

    passthru = prevAttrs.passthru // {
      tests.nixos = nixosTests.credentialsd;
      updateScript = nix-update-script {
        extraArgs = [ "--version=branch" ];
      };
    };

    meta = prevAttrs.meta // {
      description = "Desktop integration portals for sandboxed apps, built from git main";
      changelog = "https://github.com/flatpak/xdg-desktop-portal/commits/${finalAttrs.src.rev}";
      maintainers = [ lib.maintainers.skyesoss ];
    };
  }
)
