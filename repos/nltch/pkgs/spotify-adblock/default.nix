{
  spotify,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  xorg,
  zip,
  unzip,
}: let
  spotify-adblock = rustPlatform.buildRustPackage {
    pname = "spotify-adblock";
    version = "lastcommit at 2025-05-20";
    src = fetchFromGitHub {
      owner = "abba23";
      repo = "spotify-adblock";
      rev = "refs/heads/main";
      fetchSubmodules = false;
      hash = "sha256-nwiX2wCZBKRTNPhmrurWQWISQdxgomdNwcIKG2kSQsE=";
    };
    cargoHash = "sha256-oGpe+kBf6kBboyx/YfbQBt1vvjtXd1n2pOH6FNcbF8M=";

    patchPhase = ''
      substituteInPlace src/lib.rs \
        --replace 'config.toml' $out/etc/spotify-adblock/config.toml
    '';

    buildPhase = ''
      make
    '';

    installPhase = ''
      mkdir -p $out/etc/spotify-adblock
      install -D --mode=644 config.toml $out/etc/spotify-adblock
      mkdir -p $out/lib
      install -D --mode=644 --strip target/release/libspotifyadblock.so $out/lib
    '';
  };
spotifywm = stdenv.mkDerivation {
    name = "spotifywm";
    src = fetchFromGitHub {
      owner = "dasj";
      repo = "spotifywm";
      rev = "8624f539549973c124ed18753881045968881745";
      hash = "sha256-AsXqcoqUXUFxTG+G+31lm45gjP6qGohEnUSUtKypew0=";
    };
    buildInputs = [xorg.libX11];
    installPhase = "mv spotifywm.so $out";
  };
in
  spotify.overrideAttrs (
    old: {
      buildInputs = (old.buildInputs or [ ]) ++ [ zip unzip ];
      postInstall =
        (old.postInstall or "")
        + ''
          ln -s ${spotify-adblock}/lib/libspotifyadblock.so $libdir
          sed -i "s:^Name=Spotify.*:Name=Spotify-adblock:" "$out/share/spotify/spotify.desktop"
          wrapProgram $out/bin/spotify \
            --set LD_PRELOAD "${spotify-adblock}/lib/libspotifyadblock.so"

          # Hide placeholder for advert banner
          ${unzip}/bin/unzip -p $out/share/spotify/Apps/xpui.spa xpui-snapshot.js | sed 's/adsEnabled:\!0/adsEnabled:false/' > $out/share/spotify/Apps/xpui-snapshot.js
          ${zip}/bin/zip --junk-paths --update $out/share/spotify/Apps/xpui.spa $out/share/spotify/Apps/xpui-snapshot.js
          rm $out/share/spotify/Apps/xpui-snapshot.js
        '';
    }
  )
