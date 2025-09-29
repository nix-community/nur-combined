{
  stdenv,
  lib,
  fetchurl,
  pkgs,
  ...
}:

let
  major = "5.1.5";
  minor = "105";
  postfix = "release";
  fullVersion = "${major}.${minor}";
  fullVersionPostfix = "${fullVersion}-${postfix}";

  repo = "https://sdk-repo.omprussia.ru/sdk/installers/${major}/${fullVersionPostfix}/AuroraPSDK";
  chrootB = "Aurora_OS-${fullVersion}-MB2-Aurora_Platform_SDK_Chroot-x86_64.tar.bz2";

  chroot = fetchurl {
    url = "${repo}/${chrootB}";
    sha256 = "sha256-X27z+QPNGH9zFm7p3SCxCUgVnqO6eMuqL1qSRBwr7dI=";
  };

  hadk-env = ./hadk-env;
  hw-profile = ./hw-profile;
  mersdkubu-profile = ./mersdkubu-profile;
in
stdenv.mkDerivation {
  pname = "auroraos-platform-sdk";
  version = "${fullVersionPostfix}";

  nativeBuildInputs = with pkgs; [
    gnutar
    coreutils
    gnused
    su
    sudo
    bash
  ];

  dontUnpack = true;

  installPhase = ''
    # Create a wrapper script that sets up the user-level environment
    mkdir -p $out/bin
    cat > $out/bin/aurora_psdk << 'EOF'
    #!${pkgs.runtimeShell}
    set -e

    user=$(whoami)

    # Use XDG_DATA_HOME or fallback to ~/.local/share
    PSDK_BASE_DIR=''${AURORA_PSDK_DATA_DIR:-''${XDG_DATA_HOME:-$HOME/.local/share}/aurora_psdk}
    PSDK_CHROOT_DIR=$PSDK_BASE_DIR/sdks/aurora_psdk

    # Initialize on first run
    if [ ! -f $PSDK_BASE_DIR/.initialized ]; then
      echo "[*] Setting up AuroraPSDK chroot in $PSDK_BASE_DIR..."
      mkdir -p $PSDK_CHROOT_DIR $PSDK_BASE_DIR/toolings $PSDK_BASE_DIR/targets

      sudo tar --numeric-owner \
        --preserve-permissions \
        --extract \
        --auto-compress \
        --file ${chroot} \
        --exclude='dev/*' \
        --checkpoint=.1000 \
        --directory $PSDK_CHROOT_DIR
            
      # Fix bash prompt for Nix systems
      sudo sed -i "s|#!/bin/bash|#!${pkgs.runtimeShell}|" $PSDK_CHROOT_DIR/sdk-chroot

      # Add user hooks
      echo -e "\n[*] Setting .hw.profile, .hadk.env, .mersdkubu.profile in $HOME"
      sudo install -o $user -Dm0755 ${hadk-env} $HOME/.hadk.env
      sudo install -o $user -Dm0755 ${hw-profile} $HOME/.hw.profile
      sudo install -o $user -Dm0755 ${mersdkubu-profile} $HOME/.mersdkubu.profile

      touch $PSDK_BASE_DIR/.initialized
      echo "[*] AuroraPSDK setup complete."
    fi

    ${pkgs.bash}/bin/bash $PSDK_CHROOT_DIR/sdk-chroot /bin/bash -c "
    source /etc/bash_completion.d/sb2.bash
    source /etc/bash_completion.d/zypper.sh
    test \$# -eq 0 && exec bash --init-file \$HOME/.hw.profile || exec bash --init-file \$HOME/.hw.profile -c \"\$@\"
    " -- "$@"

    EOF

    chmod +x $out/bin/aurora_psdk
  '';

  meta = {
    license = lib.licenses.unfree;
    homepage = "https://developer.auroraos.ru/downloads/p_sdk/${fullVersion}";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    description = "Aurora OS Platform SDK";
    platforms = [ "x86_64-linux" ];
    mainProgram = "aurora_psdk";
  };
}
