{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, spotify # unfree
, curl
, wrapSpotify ? true # set to false if you need only lib/libspotifyadblock.so
}:

let

  spotify-adblock = rustPlatform.buildRustPackage rec {
    pname = "spotify-adblock";
    version = "1.0.3";

    src = fetchFromGitHub {
      owner = "abba23";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-UzpHAHpQx2MlmBNKm2turjeVmgp5zXKWm3nZbEo0mYE=";
    };

    # add $out/etc/spotify-adblock/config.toml to config_paths
    # fix: Error: No config file
    postPatch = ''
      substituteInPlace src/lib.rs \
        --replace-fail \
          'PathBuf::from("/etc/spotify-adblock/config.toml"),' \
          'PathBuf::from("/etc/spotify-adblock/config.toml"), PathBuf::from("'$out'/etc/spotify-adblock/config.toml"),'
    '';

    configUrl = "https://raw.githubusercontent.com/${src.owner}/${src.repo}/main/config.toml";

    cargoSha256 = "sha256-wPV+ZY34OMbBrjmhvwjljbwmcUiPdWNHFU3ac7aVbIQ=";

    # FIXME "cargo test" rebuilds all dependencies
    # maybe because "cargo test" runs in a different env than "
    # ++ env CC_X86_64_UNKNOWN_LINUX_GNU=... CXX_X86_64_UNKNOWN_LINUX_GNU=... \
    #    CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=... CC_X86_64_UNKNOWN_LINUX_GNU=... \
    #    CXX_X86_64_UNKNOWN_LINUX_GNU=... CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=... \
    #    CARGO_BUILD_TARGET=x86_64-unknown-linux-gnu HOST_CC=... HOST_CXX=... \
    #    cargo build -j 3 --target x86_64-unknown-linux-gnu --frozen --profile release
    # ++ cargo test  -j 3 --profile release --target x86_64-unknown-linux-gnu --frozen -- --test-threads=3

    # tests are a waste of time
    doCheck = false;

    postInstall = ''
      mkdir -p $out/etc/spotify-adblock
      cp config.toml $out/etc/spotify-adblock
    '';

    meta = with lib; {
      description = "Adblocker for Spotify";
      homepage = "https://github.com/abba23/spotify-adblock";
      license = licenses.unlicense;
      maintainers = [ ];
    };
  };

in

if (!wrapSpotify) then spotify-adblock else

let
  preExec = ''
    # autoupdate is default off, because config.toml almost never changes
    config_dir=$HOME/.config/spotify-adblock
    if ! [ -e $config_dir/enable-autoupdate ]; then
      echo "autoupdate is off"
      echo "to enable autoupdate, run: mkdir -p $config_dir && touch $config_dir/enable-autoupdate"
    else
      echo "autoupdate is on"
      echo "to disable autoupdate, run: rm $config_dir/enable-autoupdate"
      echo "to view the autoupdate history, run: git -C $config_dir log"
      max_config_age=$((60 * 60 * 24 * 30)) # 30 days
      pushd $config_dir >/dev/null
      if [ -e config.toml ]; then
        config_age=$(( $(date +%s) - $(stat -c%Y config.toml) ))
        echo "$config_dir/config.toml age: $config_age"
      else
        echo "$config_dir/config.toml not found"
        config_age=$max_config_age
      fi
      if (( config_age < max_config_age )); then
        echo "blocklist is up to date"
      else
        echo "updating blocklist"
        function git_commit() {
          GIT_AUTHOR_NAME="autoupdate" GIT_AUTHOR_EMAIL="" \
          GIT_COMMITTER_NAME="autoupdate" GIT_COMMITTER_EMAIL="" \
          git commit -m "$1"
        }
        [ -d .git ] || git -c init.defaultBranch=main init
        if ! [ -e config.toml ]; then
          cp ${spotify-adblock}/etc/spotify-adblock/config.toml .
          chmod +w config.toml
          git add config.toml
          git_commit "init config.toml"
        fi
        # this will update mtime and reset config_age to zero
        if ${curl}/bin/curl --max-time 5 ${spotify-adblock.configUrl} -o config.toml; then
          git add config.toml
          # "git commit" fails if there was no change
          git_commit "update config.toml" || true
        fi
        popd >/dev/null
      fi
      pushd $config_dir >/dev/null
    fi
    export LD_PRELOAD=${spotify-adblock}/lib/libspotifyadblock.so
  '';
in

stdenv.mkDerivation {
  inherit (spotify-adblock) pname version meta;
  buildInputs = [ spotify-adblock spotify curl ];
  buildCommand = ''
    mkdir -p $out/bin
    cp ${spotify}/bin/spotify $out/bin/spotify-adblock
    chmod +w $out/bin/spotify-adblock
    # add code before "exec"
    substituteInPlace $out/bin/spotify-adblock \
      --replace-fail "exec -a" ${lib.escapeShellArg preExec}"exec -a"
  '';
}
