{
  pkgs,
  ...
}: let
  flutterLinuxPkgConfigPath = pkgs.lib.makeSearchPath "lib/pkgconfig" [
    pkgs.gtk3.dev
    pkgs.glib.dev
    pkgs.pango.dev
    pkgs.cairo.dev
    pkgs.gdk-pixbuf.dev
    pkgs.atk.dev
    pkgs.at-spi2-atk.dev
    pkgs.harfbuzz.dev
    pkgs.libsecret.dev
  ];

  androidSdk = pkgs.androidenv.composeAndroidPackages { # Match the Android API/build-tool levels used by current Flutter projects.
    platformVersions = [
      "34"
      "35"
    ];
    abiVersions = [
      "armeabi-v7a"
      "arm64-v8a"
    ];
    buildToolsVersions = [
      "34.0.0"
      "35.0.0"
    ];
    includeEmulator = true; # Keep local emulator development available without a separate SDK install.
    includeSources = false;
    includeSystemImages = true;
    includeNDK = false;
    includeExtras = [
      "extras;google;m2repository"
      "extras;android;m2repository"
    ];
  };

  # Helper script to fix Android SDK structure for Flutter
  # Flutter expects cmdline-tools/latest/bin/sdkmanager
  # Nix provides cmdline-tools/bin/sdkmanager
  fixFlutterAndroid = pkgs.writeScriptBin "fix-flutter-android" ''
        #!${pkgs.stdenv.shell}
        SDK_ROOT=$HOME/Android/Sdk
        mkdir -p $SDK_ROOT

        ensure_managed_sdk_link() {
          source="$1"
          destination="$2"

          if [ -e "$destination" ] && [ ! -L "$destination" ]; then
            echo "Refusing to replace non-symlink Android SDK component: $destination" >&2
            return 1
          fi

          ln -sfn "$source" "$destination"
        }

        # Symlink Nix-managed SDK components to a local folder.
        for dir in platforms platform-tools build-tools emulator system-images; do
          if [ -d "${androidSdk.androidsdk}/libexec/android-sdk/$dir" ]; then
            ensure_managed_sdk_link "${androidSdk.androidsdk}/libexec/android-sdk/$dir" "$SDK_ROOT/$dir"
          fi
        done

        # Fix cmdline-tools structure. The marker identifies the directory as
        # managed by this script and prevents replacing a user-managed SDK.
        # Flutter probes cmdline-tools/latest/bin/sdkmanager.
        # We provide a local wrapper that always uses --sdk_root=$SDK_ROOT.
        if [ -e "$SDK_ROOT/cmdline-tools" ] && [ ! -f "$SDK_ROOT/cmdline-tools/.nix-flutter-managed" ]; then
          echo "Refusing to replace user-managed Android SDK component: $SDK_ROOT/cmdline-tools" >&2
          exit 1
        fi
        mkdir -p "$SDK_ROOT/cmdline-tools"
        touch "$SDK_ROOT/cmdline-tools/.nix-flutter-managed"
        VERSIONED_DIR=$(ls -1 "${androidSdk.androidsdk}/libexec/android-sdk/cmdline-tools" | head -n 1)
        if [ -n "$VERSIONED_DIR" ]; then
          ln -sfn "${androidSdk.androidsdk}/libexec/android-sdk/cmdline-tools/$VERSIONED_DIR" "$SDK_ROOT/cmdline-tools/$VERSIONED_DIR"
          mkdir -p "$SDK_ROOT/cmdline-tools/latest/bin"
          cat > "$SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" <<EOF
    #!/usr/bin/env sh
    exec "${androidSdk.androidsdk}/libexec/android-sdk/cmdline-tools/$VERSIONED_DIR/bin/sdkmanager" --sdk_root="$SDK_ROOT" "\$@"
    EOF
          chmod +x "$SDK_ROOT/cmdline-tools/latest/bin/sdkmanager"
          cat > "$SDK_ROOT/cmdline-tools/latest/bin/avdmanager" <<EOF
    #!/usr/bin/env sh
    exec "${androidSdk.androidsdk}/libexec/android-sdk/cmdline-tools/$VERSIONED_DIR/bin/avdmanager" --sdk_root="$SDK_ROOT" "\$@"
    EOF
          chmod +x "$SDK_ROOT/cmdline-tools/latest/bin/avdmanager"
          echo "Linked cmdline-tools version $VERSIONED_DIR"
        fi

        # Create writable licenses folder without deleting user-provided hashes.
        mkdir -p "$SDK_ROOT/licenses"
        if [ -d "${androidSdk.androidsdk}/libexec/android-sdk/licenses" ]; then
          cp -rL "${androidSdk.androidsdk}/libexec/android-sdk/licenses/." "$SDK_ROOT/licenses/"
        fi
        chmod -R u+w "$SDK_ROOT/licenses" || true
        # Persist additional license hashes expected by sdkmanager/flutter.
        # This avoids re-prompting after Nix SDK refreshes.
        cat > "$SDK_ROOT/licenses/android-sdk-license" <<'EOF'
    24333f8a63b6825ea9c5514f83c2829b004d1fee
    EOF
        cat > "$SDK_ROOT/licenses/android-sdk-preview-license" <<'EOF'
    84831b9409646a918e30573bab4c9c91346d8abd
    EOF
        cat > "$SDK_ROOT/licenses/android-googletv-license" <<'EOF'
    601085b94cd77f0b54ff86406957099ebe79c4d6
    EOF
        cat > "$SDK_ROOT/licenses/android-googlexr-license" <<'EOF'
    ceff83576aac4f7f37cb98fe189e9fb3c49d3b81
    EOF
        cat > "$SDK_ROOT/licenses/android-sdk-arm-dbt-license" <<'EOF'
    859f317696f67ef3d7f30a50a5560e7834b43903
    EOF
        cat > "$SDK_ROOT/licenses/google-gdk-license" <<'EOF'
    33b6a2b64607f11b759f320ef9dff4ae5c47d97a
    EOF
        cat > "$SDK_ROOT/licenses/mips-android-sysimage-license" <<'EOF'
    e9acab5b5fbb560a72cfaecce8946896ff6aab9d
    EOF

        echo "Android SDK structure fixed in $SDK_ROOT"
  '';

in {
  environment = {
    systemPackages = with pkgs; [
      # Flutter & Android
      dart
      fvm
      androidSdk.androidsdk
      fixFlutterAndroid
      ktlint

      # Linux Development
      gtk3
      gtk3.dev
      glib
      glib.dev
      pango
      pango.dev
      cairo
      cairo.dev
      gdk-pixbuf
      gdk-pixbuf.dev
      atk
      atk.dev
      at-spi2-atk
      at-spi2-atk.dev
      harfbuzz
      harfbuzz.dev
      libsecret
      libsecret.dev
      libwebp
      jsoncpp
      pkg-config

      # Graphics
      libglvnd
      mesa
      mesa-demos
      egl-wayland
    ];
    variables = {
      ANDROID_HOME = "$HOME/Android/Sdk";
      ANDROID_SDK_ROOT = "$HOME/Android/Sdk";
    };
    sessionVariables = {
      # Updated ANDROID_HOME to point to our structured local folder
      ANDROID_HOME = "$HOME/Android/Sdk";
      ANDROID_SDK_ROOT = "$HOME/Android/Sdk";
      JAVA_HOME = "${pkgs.jdk17}/lib/openjdk";
      PKG_CONFIG_PATH = flutterLinuxPkgConfigPath;
    };
  };

  nixpkgs.config.android_sdk.accept_license = true;

  # Activation Scripts
  # Keep Flutter SDK layout and Android licenses synced after each system switch.
  # Runs as user "ac" so files in $HOME/Android/Sdk keep correct ownership.
  system.activationScripts.fixFlutterAndroid = {
    deps = ["users"];
    text = ''
      if [ -d /home/ac ]; then
        echo "Running fix-flutter-android for user ac..."
        ${pkgs.util-linux}/bin/runuser -u ac -- \
          ${pkgs.coreutils}/bin/env HOME=/home/ac USER=ac \
          ${fixFlutterAndroid}/bin/fix-flutter-android || true
      fi
    '';
  };

}
