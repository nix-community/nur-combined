{ pkgs, lib, ... }:

let
  dockerImage = pkgs.dockerTools.pullImage {
    imageName = "hub.omp.ru/public/sdk-build-tools";
    imageDigest = "sha256:7e9cbced02b42f8addb224e2eecf4a73e31e7581e7a0d68812b0df20857aaaaf";
    hash = "sha256-t/fGS1NxtFuJgRyldWa6DkUJjb1lL+NJzL8zX8ydDhQ=";
    finalImageName = "hub.omp.ru/public/sdk-build-tools";
    finalImageTag = "latest";
  };

in pkgs.stdenv.mkDerivation {
  name = "auroraos-asbt-apptool";
  version = "1.0";

  nativeBuildInputs = with pkgs; [
    proot
  ];

  phases = [ "buildPhase" "installPhase" ];

  buildPhase = ''
    # Create temporary directory for extraction
    mkdir -p $out/rootfs
    mkdir image_tmp
    
    # Extract the docker image tar
    tar -xf ${dockerImage} -C image_tmp
    
    # Extract all layers in the correct order
    for layer in $(find image_tmp -name "*.tar" | grep layer.tar | sort); do
      echo "Extracting layer: $(basename $(dirname $layer))"
      tar -xf "$layer" -C $out/rootfs
    done
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/rootfs
    
    # Copy the complete rootfs
    cp -r rootfs/* $out/rootfs/ 2>/dev/null || true
    
    # Create the apptool launcher
    cat > $out/bin/apptool << 'EOF'
    #!${pkgs.runtimeShell}
    set -e
    
    BIND_MOUNTS="$BIND_MOUNTS -b $PWD:/mnt"
    
    exec ${pkgs.proot}/bin/proot \
      -r ${placeholder "out"}/rootfs \
      -b /dev -b /proc -b /sys -b /tmp -b /run -b /var \
      -w /mnt \
      /usr/bin/apptool "$@"
    EOF
    
    chmod +x $out/bin/apptool
  '';

  meta = {
    license = lib.licenses.unfree;
    homepage = "https://developer.auroraos.ru/doc/sdk/tools/apptool";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ "dmfrpro" ];
    description = "AuroraOS SDK Build Tools - apptool";
    longDescription = ''
      Tool for cross-building, signing and validation of RPM packages.
      It is a high-level wrapper around rpmbuild, rpmspec, rpmsign-external and rpm-validator.
    '';
    platforms = [ "x86_64-linux" ];
    mainProgram = "apptool";
  };
}
