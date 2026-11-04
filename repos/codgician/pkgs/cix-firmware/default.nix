{
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
}:

# CIX P1 board firmware blobs (VPU codecs, Wi-Fi, Bluetooth, Mali GPU, AMD GPU,
# SFH/sensor microcode). Sourced from CIX's proprietary GitHub repo;
# these are redistributable but not built from source, so we tag the
# meta accordingly to keep `nixpkgs.config.allowUnfree` honest.
stdenv.mkDerivation (finalAttrs: {
  pname = "cix-firmware";
  # CIX publishes P1 BSP releases as `p1_v<version>` tags.
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "cixtech";
    repo = "cix_proprietary__cix_proprietary";
    tag = "p1_v${finalAttrs.version}";
    hash = "sha256-sRU/eUCZykQyO6JXwDu1IMD73aCp/n7BsNQRS3WabjI=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib/firmware"
    # Each subdirectory under cix_module_fw/ already uses the layout that
    # the corresponding kernel driver expects (e.g. amdgpu/, qca/, fc6xe/,
    # lt7911/), so we just merge them into /lib/firmware.
    for sub in cix_module_fw/*/; do
      cp -a "$sub"/. "$out/lib/firmware/"
    done
    # The VPU codec firmware is packaged separately from cix_module_fw.
    install -m644 cix_proprietary-debs/cix-vpu-umd/usr/lib/firmware/*.fwb "$out/lib/firmware/"
    runHook postInstall
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "p1_v"; };

  meta = {
    description = "Proprietary firmware blobs for the CIX P1 (Sky1) SoC";
    homepage = "https://github.com/cixtech/cix_proprietary__cix_proprietary";
    license = lib.licenses.unfreeRedistributableFirmware;
    maintainers = with lib.maintainers; [ codgician ];
    platforms = [ "aarch64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryFirmware ];
  };
})
