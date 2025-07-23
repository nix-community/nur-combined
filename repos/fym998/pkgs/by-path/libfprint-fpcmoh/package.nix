#
# https://gitlab.freedesktop.org/libfprint/libfprint/-/merge_requests/396#note_2173483
#
{
  pkgs,
  lib,
  libfprint,
  nss,
}:
let
  fpcbep = pkgs.fetchzip {
    url = "https://download.lenovo.com/pccbbs/mobiles/r1slm01w.zip";
    hash = "sha256-/buXlp/WwL16dsdgrmNRxyudmdo9m1HWX0eeaARbI3Q=";
    stripRoot = false;
  };
in
libfprint.overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "libfprint-fpcmoh";
    version = "1.94.6";
    src = pkgs.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "libfprint";
      repo = "libfprint";
      rev = "v${finalAttrs.version}";
      hash = "sha256-lDnAXWukBZSo8X6UEVR2nOMeVUi/ahnJgx2cP+vykZ8=";
    };
    patches = previousAttrs.patches or [ ] ++ [
      (pkgs.fetchpatch {
        url = "https://gitlab.freedesktop.org/libfprint/libfprint/-/merge_requests/396.patch";
        sha256 = "sha256-+5B5TPrl0ZCuuLvKNsGtpiU0OiJO7+Q/iz1+/2U4Taw=";
      })
    ];
    postPatch = (previousAttrs.postPatch or "") + ''
      substituteInPlace meson.build \
        --replace "find_library('fpcbep', required: true)" "find_library('fpcbep', required: true, dirs: '$out/lib')"
    '';
    buildInputs = previousAttrs.buildInputs or [ ] ++ [ nss ];
    preConfigure = (previousAttrs.preConfigure or "") + ''
      install -D "${fpcbep}/FPC_driver_linux_27.26.23.39/install_fpc/libfpcbep.so" "$out/lib/libfpcbep.so"
    '';
    postInstall = (previousAttrs.postInstall or "") + ''
      install -Dm644 "${fpcbep}/FPC_driver_linux_libfprint/install_libfprint/lib/udev/rules.d/60-libfprint-2-device-fpc.rules" "$out/lib/udev/rules.d/60-libfprint-2-device-fpc.rules"
      substituteInPlace "$out/lib/udev/rules.d/70-libfprint-2.rules" --replace "/bin/sh" "${pkgs.runtimeShell}"
    '';
    meta = previousAttrs.meta // {
      description = "libfprint with proprietary FPC match on host device 10a5:9800 driver";
      homepage = "https://aur.archlinux.org/packages/libfprint-fpcmoh-git";
      platforms = [ "x86_64-linux" ];
      license = lib.licenses.unfreeRedistributableFirmware;
      sourceProvenance = with lib.sourceTypes; [ binaryFirmware ];
    };
  }
)
