{ pkgs, ... }:

let
  version = {
    major = "5.2.0";
    minor = "180";
    postfix = "release";
    full = "${version.major}.${version.minor}";
    fullPostfix = "${version.full}-${version.postfix}";
  };

  repoBasePrefix = "https://sdk-repo.omprussia.ru/sdk/installers";
  repoBase = "${repoBasePrefix}/${version.major}/${version.fullPostfix}/AuroraPSDK";

  basenames = {
    chroot = "Aurora_OS-${version.full}-Aurora_Platform_SDK_Chroot-x86_64.tar.bz2";
    tooling = "Aurora_OS-${version.full}-Aurora_SDK_Tooling-x86_64.tar.7z";
    targets = {
      armv7hl = "Aurora_OS-${version.full}-Aurora_SDK_Target-armv7hl.tar.7z";
      aarch64 = "Aurora_OS-${version.full}-Aurora_SDK_Target-aarch64.tar.7z";
      x86_64 = "Aurora_OS-${version.full}-Aurora_SDK_Target-x86_64.tar.7z";
    };
  };

  fetched = {
    chroot = pkgs.fetchurl {
      url = "${repoBase}/${basenames.chroot}";
      sha256 = "sha256-A2Knqb+hKuz4YxBjo0IVrhnft+2TbSV3It7VDg0bS/4=";
    };

    tooling = pkgs.fetchurl {
      url = "${repoBase}/${basenames.tooling}";
      sha256 = "sha256-aRfj4S8sAhaFaCq85r8hKWX1anK9V0KAzCw9OiLI8mI=";
    };

    targets = {
      armv7hl = pkgs.fetchurl {
        url = "${repoBase}/${basenames.targets.armv7hl}";
        sha256 = "sha256-e00jm6IQYzo9uOWN+DBzRaTPYJdNdK7cUY/6ZrFMz7o=";
      };
      aarch64 = pkgs.fetchurl {
        url = "${repoBase}/${basenames.targets.aarch64}";
        sha256 = "sha256-P6owxR1zhRXtVRqMWFszkR4ih8xX0VdUumunU9twE9I=";
      };
      x86_64 = pkgs.fetchurl {
        url = "${repoBase}/${basenames.targets.x86_64}";
        sha256 = "sha256-7VD+2DYBBcaGRo+NErUqIa2VFKsw5Tz3oxkJrUl2QkM=";
      };
    };
  };

  ubuntuChrootImage = pkgs.dockerTools.pullImage {
    imageName = "dmfrpro/ubuntu-trusty-android-rootfs";
    imageDigest = "sha256:9cd74477a5a2110e1f69ba40b5f1debe946e2b3b39cb1fc1ee324b69ec41812b";
    hash = "sha256-599BGTxZmGgrogj939O68tJn5ZCNOZio+Pq09nvmSmI=";
    finalImageName = "dmfrpro/ubuntu-trusty-android-rootfs";
    finalImageTag = "latest";
  };

  profileFiles = {
    hadkEnv = ./hadk-env;
    hwProfile = ./hw-profile;
    mersdkUbuProfile = ./mersdkubu-profile;
  };

  scripts = {
    initTools = pkgs.writeShellScript "init-tools.sh" ''
      source "$HOME/.hw.profile"
      source "$HOME/.hadk.env"

      TOOLING_NAME="AuroraOS-${version.fullPostfix}"

      echo "Creating tooling: $TOOLING_NAME"
      sdk-assistant --non-interactive tooling create \
        "$TOOLING_NAME" "/var/tmp/${basenames.tooling}"

      echo "Creating target: ''${TOOLING_NAME}-armv7hl"
      sdk-assistant --non-interactive target create \
        "''${TOOLING_NAME}-armv7hl" "/var/tmp/${basenames.targets.armv7hl}"

      echo "Creating target: ''${TOOLING_NAME}-aarch64"
      sdk-assistant --non-interactive target create \
        "''${TOOLING_NAME}-aarch64" "/var/tmp/${basenames.targets.aarch64}"

      echo "Creating target: ''${TOOLING_NAME}-x86_64"
      sdk-assistant --non-interactive target create \
        "''${TOOLING_NAME}-x86_64" "/var/tmp/${basenames.targets.x86_64}"
    '';

    extractDockerImage = pkgs.writeShellScript "extract-docker-image.sh" ''
      set -e
      image_tarball="$1"
      output_dir="$2"

      tmpdir=$(mktemp -d)
      tar -xf "$image_tarball" -C "$tmpdir"

      layers=$(${pkgs.jq}/bin/jq -r '.[0].Layers[]' "$tmpdir/manifest.json")

      for layer in $layers; do
        tar -xf "$tmpdir/$layer" -C "$output_dir"
      done

      rm -rf "$tmpdir"
    '';

    wrapper = pkgs.writeShellScript "psdk" ''
      set -e

      export LD_LIBRARY_PATH="${pkgs.sssd}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      user=$(whoami)

      PSDK_BASE_DIR=''${AURORA_PSDK_DATA_DIR:-''${XDG_DATA_HOME:-$HOME/.local/share}/aurora_psdk}
      PSDK_CHROOT_DIR=$PSDK_BASE_DIR/sdks/aurora_psdk
      PSDK_UBUCHROOT_DIR=$PSDK_CHROOT_DIR/srv/mer/ubu-chroot

      if [ ! -f "$PSDK_BASE_DIR/.initialized" ]; then
        echo "[*] Setting up AuroraPSDK chroot in $PSDK_BASE_DIR..."
        mkdir -p "$PSDK_CHROOT_DIR" "$PSDK_BASE_DIR/toolings" \
          "$PSDK_BASE_DIR/targets"

        sudo tar --numeric-owner \
          --preserve-permissions \
          --extract \
          --auto-compress \
          --file ${fetched.chroot} \
          --exclude='dev/*' \
          --checkpoint=.1000 \
          --directory "$PSDK_CHROOT_DIR"

        echo -e "\n[*] Setting up AuroraPSDK ubu-chroot in $PSDK_UBUCHROOT_DIR..."
        sudo mkdir -p "$PSDK_UBUCHROOT_DIR"
        sudo ${scripts.extractDockerImage} ${ubuntuChrootImage} \
          "$PSDK_UBUCHROOT_DIR"

        echo -e "\n[*] Setting .hw.profile, .hadk.env, .mersdkubu.profile in $HOME"
        sudo install -o "$user" -Dm0755 ${profileFiles.hadkEnv} \
          "$HOME/.hadk.env"
        sudo install -o "$user" -Dm0755 ${profileFiles.hwProfile} \
          "$HOME/.hw.profile"
        sudo install -o "$user" -Dm0755 ${profileFiles.mersdkUbuProfile} \
          "$HOME/.mersdkubu.profile"

        echo "[*] Setting up tooling and targets..."

        sudo cp ${fetched.tooling} \
          "$PSDK_CHROOT_DIR/var/tmp/${basenames.tooling}"
        sudo cp ${fetched.targets.armv7hl} \
          "$PSDK_CHROOT_DIR/var/tmp/${basenames.targets.armv7hl}"
        sudo cp ${fetched.targets.aarch64} \
          "$PSDK_CHROOT_DIR/var/tmp/${basenames.targets.aarch64}"
        sudo cp ${fetched.targets.x86_64} \
          "$PSDK_CHROOT_DIR/var/tmp/${basenames.targets.x86_64}"

        sudo cp ${scripts.initTools} \
          "$PSDK_CHROOT_DIR/var/tmp/init-tools.sh"
        sudo chmod +x "$PSDK_CHROOT_DIR/var/tmp/init-tools.sh"

        sudo chown -R "$user" "$PSDK_CHROOT_DIR/var/tmp/"

        sudo "$PSDK_CHROOT_DIR/sdk-chroot" /bin/bash /var/tmp/init-tools.sh

        sudo rm -f "$PSDK_CHROOT_DIR/var/tmp/"{ \
          ${basenames.tooling}, \
          ${basenames.targets.armv7hl}, \
          ${basenames.targets.aarch64}, \
          ${basenames.targets.x86_64}, \
          init-tools.sh \
        }

        touch "$PSDK_BASE_DIR/.initialized"
      fi

      ${pkgs.bash}/bin/bash "$PSDK_CHROOT_DIR/sdk-chroot" /bin/bash -c "
      source /etc/bash_completion.d/sb2.bash
      source /etc/bash_completion.d/zypper.sh
      test \$# -eq 0 && exec bash --init-file \$HOME/.hw.profile \
        || exec bash --init-file \$HOME/.hw.profile -c \"\$@\"
      " -- "$@"
    '';
  };

in
pkgs.stdenv.mkDerivation {
  pname = "auroraos-platform-sdk";
  version = version.fullPostfix;

  nativeBuildInputs = with pkgs; [
    gnutar
    coreutils
    su
    sudo
    bash
    jq
    sssd
  ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 ${scripts.wrapper} $out/bin/psdk
  '';

  meta = {
    license = pkgs.lib.licenses.unfree;
    homepage = "https://developer.auroraos.ru/downloads/archive/p_sdk";
    sourceProvenance = [
      pkgs.lib.sourceTypes.binaryNativeCode
    ];
    description = "Aurora OS Platform SDK";
    maintainers = [ "dmfrpro" ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "psdk";
  };
}
