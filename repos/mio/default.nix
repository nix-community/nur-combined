# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> {
    #config.permittedInsecurePackages = [
    #  "qtwebengine-5.15.19"
    #];
    config.allowUnfree = true;
  },
  nurbot ? true,
}:
with (import ./private.nix { inherit pkgs; });
let
  inherit (pkgs) callPackage;
in
{
  # note: some packages might be commented out to reduce package numbers. garnix has hardcoded limit of 100.
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
}
// import ./packages.nix { inherit pkgs nurbot; }
// rec {
  aria2 = v3override (
    pkgs.aria2.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        (pkgs.fetchpatch {
          name = "fix patch aria2 fast.patch";
          url = "https://github.com/agalwood/aria2/commit/baf6f1d02f7f8b81cd45578585bdf1152d81f75f.patch";
          sha256 = "sha256-bLGaVJoHuQk9vCbBg2BOG79swJhU/qHgdkmYJNr7rIQ=";
        })
      ];
    })
  );
  aria2-wrapped = pkgs.writeShellScriptBin "aria2" ''
    ${aria2}/bin/aria2c -s65536 -j65536 -x256 -k1k --file-allocation=none "$@"
  '';
  caddy =
    let
      # Table mapping NixOS version + Caddy version + Go version to plugins hash
      # Key format: "<nixosVersion>:<caddyVersion>:<goVersion>"
      caddyPluginsHashTable = {
        "26.05:2.11.3:go1.26.3" = "sha256-0TRYdgQthch/FWqRIcbISHLUQK9UH9VUpEzN3vMeUo0=";
        "26.11:2.11.3:go1.26.3" = "sha256-0TRYdgQthch/FWqRIcbISHLUQK9UH9VUpEzN3vMeUo0=";
        "26.11:2.11.4:go1.26.3" = "sha256-gg2FrWBzumTkp77AA5faAPOQx68JzureGMignc0r1lA=";
        "26.05:2.11.4:go1.26.3" = "sha256-gg2FrWBzumTkp77AA5faAPOQx68JzureGMignc0r1lA=";
        "26.05:2.11.4:go1.26.4" = "sha256-Bv00eNLSJof+kWkLaJAPRjGzaXd/gvKoPt9fmBYG3uw=";
        "26.11:2.11.4:go1.26.4" = "sha256-Bv00eNLSJof+kWkLaJAPRjGzaXd/gvKoPt9fmBYG3uw=";
      };
      nixosVersion = pkgs.lib.versions.majorMinor pkgs.lib.version;
      caddyVersion = pkgs.caddy.version;
      goVersion = pkgs.caddy.passthru.go.version;
      lookupKey = "${nixosVersion}:${caddyVersion}:go${goVersion}";
      pluginsHash =
        caddyPluginsHashTable.${lookupKey}
          or (throw "Unknown caddy version combination: ${lookupKey}. Please update caddyPluginsHashTable in default.nix");
    in
    (goV3OverrideAttrs pkgs.caddy).withPlugins {
      # https://github.com/crowdsecurity/example-docker-compose/blob/main/caddy/Dockerfile
      # https://github.com/NixOS/nixpkgs/pull/358586
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.2.4"
        "github.com/porech/caddy-maxmind-geolocation@v1.0.3"
        # "github.com/hslatman/caddy-crowdsec-bouncer/http@main"
      ];
      hash = pluginsHash;
    };
  telegram-desktop_patched = pkgs.telegram-desktop.overrideAttrs (old: {
    unwrapped = v3overridegcc (
      old.unwrapped.overrideAttrs (old2: {
        # see https://github.com/Layerex/telegram-desktop-patches
        patches = (pkgs.telegram-desktop.unwrapped.patches or [ ]) ++ [
          ./patches/0001-telegramPatches.patch
        ];
      })
    );
  });
  materialgram_patched = pkgs.materialgram.overrideAttrs (old: {
    unwrapped = v3overridegcc (
      old.unwrapped.overrideAttrs (old2: {
        # see https://github.com/Layerex/telegram-desktop-patches
        patches = (pkgs.materialgram.unwrapped.patches or [ ]) ++ [
          ./patches/0001-materialgramPatches.patch
        ];
      })
    );
  });
  openssh = v3override (
    (pkgs.openssh_10_2 or pkgs.openssh).overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./patches/openssh.patch ];
      #doCheck = false;
    })
  );
  openssh_hpn = v3override (
    pkgs.openssh_hpn.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./patches/openssh.patch ];
    })
  );
  grub2 = nodarwin (
    v3overridegcc (
      pkgs.grub2.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./patches/grub-os-prober-title.patch ];
      })
    )
  );
  bees = nodarwin (v3overridegcc pkgs.bees);
  netdata = (v3override (goV3OverrideAttrs pkgs.netdata)).override { withCloudUi = true; };
  # https://gist.github.com/nstarke/baa031e0cab64a608c9bd77d73c50fc6
  ghidra = v3override (
    pkgs.ghidra.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./patches/ghidra-ui-scale.patch ];
    })
  );
  trayscale = pkgs.trayscale.overrideAttrs (old: {
    nativeBuildInputs =
      (old.nativeBuildInputs or [ ]) ++ pkgs.lib.optional pkgs.stdenv.hostPlatform.isDarwin pkgs.libicns;
    postInstall =
      (old.postInstall or "")
      + pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        app="$out/Applications/Trayscale.app"
        mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
        ln -s "$out/bin/trayscale" "$app/Contents/MacOS/trayscale"
        png2icns "$app/Contents/Resources/trayscale.icns" "$out/share/icons/hicolor/256x256/apps/dev.deedles.Trayscale.png"
        cat > "$app/Contents/Info.plist" <<EOF
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>CFBundleExecutable</key>
          <string>trayscale</string>
          <key>CFBundleIdentifier</key>
          <string>dev.deedles.Trayscale</string>
          <key>CFBundleName</key>
          <string>Trayscale</string>
          <key>CFBundleIconFile</key>
          <string>trayscale.icns</string>
          <key>CFBundlePackageType</key>
          <string>APPL</string>
        </dict>
        </plist>
        EOF
      '';
  });

  cached-set =
    let
      self = import ./default.nix {
        inherit pkgs;
        nurbot = false;
      };
    in
    if nurbot then
      { }
    else
      {
        pkgscachelinux = (
          pkgs.symlinkJoin {
            name = "pkgscachelinux";
            paths = with self; [
              rain
              wireguird
            ];
          }
        );
        pkgscachelinuxextra = (
          pkgs.symlinkJoin {
            name = "pkgscachelinuxextra";
            paths = with self; [
            ];
          }
        );
        pkgscachecommon = (
          pkgs.symlinkJoin {
            name = "pkgscachecommon";
            paths = with self; [
              aria2
              aria2-wrapped
              openssh_hpn
              caddy
              minetest591client
              minetest580client
              musescore-alex
            ];
          }
        );
        pkgscachex86linux = (
          pkgs.symlinkJoin {
            name = "pkgscache";
            paths = with self; [
              self.materialgram_patched
              self.telegram-desktop_patched
              lmms
              cb
              beammp-launcher
              mdbook-generate-summary
              #betterbird
              eden
              ghidra
              trayscale
              prismlauncher-diegiwg
              android-translation-layer
              #pake # started failing recently
              cider
              rocksmith2tab
              #nix-output-monitor
              darling
              supertuxkart-evolution
            ];
          }
        );
      };
}
