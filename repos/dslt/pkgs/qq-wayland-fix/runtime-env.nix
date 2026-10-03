# Post-install adaptation shared by the two launcher packages. The upstream
# launcher and its desktop entry assume a distro layout and a distro runtime;
# this snippet is meant to run with $out set, after the files are installed.
#
# - PATH: the launcher and --doctor call pgrep, systemctl, wayland-info, grep,
#   sed, awk, ls, xargs and od, none of which are guaranteed to be in PATH when
#   the desktop entry starts the launcher.
# - LD_LIBRARY_PATH: QQ's resources/app/avsdk/broadcast-core.so dlopens
#   libpipewire-0.3.so.0 and libva.so by bare name. NixOS has no global library
#   directory and its ld.so.cache has neither, so the dlopens fail: screen
#   sharing never opens a portal and encoding stays software-only.
#   /run/opengl-driver/lib carries the vendor codec libraries (NVENC/NVDEC/CUDA,
#   AMF, oneVPL) and is appended last so it cannot shadow store libraries.
# - EGL_PLATFORM: with no platform hint glvnd hands
#   eglGetDisplay(EGL_DEFAULT_DISPLAY) to Mesa, which cannot drive the NVIDIA
#   blob and degrades to llvmpipe (share encoding then pegs several cores). Only
#   set in Wayland sessions, and never over someone else's value.
# - VK_DRIVER_FILES: the launcher probes Vulkan for --use-angle=vulkan (the
#   upstream default that avoids garbled shared-screen playback on some devices),
#   but only looks at /usr/share/vulkan/icd.d, /etc/vulkan/icd.d and
#   XDG_DATA_HOME; NixOS keeps the ICDs in /run/opengl-driver/share/vulkan/icd.d.
# - QQ_WAYLAND_FIX_QQ / QQ_WAYLAND_FIX_QQ_ROOT: default to the packaged QQ and
#   let --doctor inspect a store-installed one instead of /opt/QQ. Both stay
#   overridable by the user's own export.
{
  lib,
  qqPackage,
  bashInteractive,
  libva,
  pipewire,
  coreutils,
  findutils,
  gawk,
  gnugrep,
  gnused,
  procps,
  systemd,
  wayland-utils,
}:

let
  runtimeTools = [
    coreutils
    findutils
    gawk
    gnugrep
    gnused
    procps # pgrep: --doctor checks whether QQ is injected
    systemd # busctl/systemctl: --doctor checks the portal and clipsync
    wayland-utils # wayland-info: --doctor checks the data-control protocol
  ];
in
''
  substituteInPlace $out/bin/linuxqq-wayland-fix \
    --replace-fail '#!/bin/bash' "#!${lib.getExe bashInteractive}" \
    --replace-fail 'set -u' 'set -u
export PATH=${lib.makeBinPath runtimeTools}:$PATH
export LD_LIBRARY_PATH=${lib.makeLibraryPath [ libva (lib.getLib pipewire) ]}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}:/run/opengl-driver/lib
if [ -z "''${EGL_PLATFORM:-}" ] && [ -n "''${WAYLAND_DISPLAY:-}" ]; then
    export EGL_PLATFORM=wayland
fi
if [ -z "''${VK_DRIVER_FILES:-}''${VK_ICD_FILENAMES:-}" ] && [ -d /run/opengl-driver/share/vulkan/icd.d ]; then
    icds=$(ls /run/opengl-driver/share/vulkan/icd.d/*.json 2>/dev/null | tr "\n" ":")
    [ -n "$icds" ] && export VK_DRIVER_FILES="''${icds%:}"
fi
: "''${QQ_WAYLAND_FIX_QQ:=${qqPackage}/bin/qq}"
: "''${QQ_WAYLAND_FIX_QQ_ROOT:=${qqPackage}/opt/QQ}"' \
    --replace-fail 'elif [[ -x /opt/QQ/qq ]]; then' 'elif [[ -x "''${QQ_WAYLAND_FIX_QQ_ROOT:-/opt/QQ}/qq" ]]; then' \
    --replace-fail '        echo /opt/QQ/qq' '        echo "''${QQ_WAYLAND_FIX_QQ_ROOT:-/opt/QQ}/qq"' \
    --replace-fail 'elif [[ -d /opt/QQ/resources/app ]]; then' 'elif [[ -d "''${QQ_WAYLAND_FIX_QQ_ROOT:-/opt/QQ}/resources/app" ]]; then' \
    --replace-fail '        echo /opt/QQ/resources/app' '        echo "''${QQ_WAYLAND_FIX_QQ_ROOT:-/opt/QQ}/resources/app"' \
    --replace-fail '/opt/QQ/resources/app/wrapper.node' '"''${QQ_WAYLAND_FIX_QQ_ROOT:-/opt/QQ}/resources/app/wrapper.node"'

  # Newer launchers inspect the running QQ (including AppImages) before falling
  # back to the installed binary. Keep that discovery and adapt only its fallback;
  # older launchers inspect the installed binary directly. Each layout must still
  # match its required substitutions so further upstream changes fail the build.
  if grep -Fq 'qq_runtime_exe() {' $out/bin/linuxqq-wayland-fix; then
    substituteInPlace $out/bin/linuxqq-wayland-fix \
      --replace-fail '[[ -x /opt/QQ/qq ]] && echo /opt/QQ/qq' \
        '[[ -x "''${QQ_WAYLAND_FIX_QQ_ROOT:-/opt/QQ}/qq" ]] && echo "''${QQ_WAYLAND_FIX_QQ_ROOT:-/opt/QQ}/qq"' \
      --replace-fail 'roots+=(/opt/QQ)' 'roots+=("''${QQ_WAYLAND_FIX_QQ_ROOT:-/opt/QQ}")'
  else
    substituteInPlace $out/bin/linuxqq-wayland-fix \
      --replace-fail 'find "$vdir" /opt/QQ -name' 'find "$vdir" "''${QQ_WAYLAND_FIX_QQ_ROOT:-/opt/QQ}" -name' \
      --replace-fail 'local qqbin=/opt/QQ/qq offs' 'local qqbin="''${QQ_WAYLAND_FIX_QQ_ROOT:-/opt/QQ}/qq" offs'
  fi

  # The menu entry must not depend on the launcher being on PATH.
  substituteInPlace $out/share/applications/linuxqq-wayland-fix.desktop \
    --replace-fail 'Exec=linuxqq-wayland-fix' "Exec=$out/bin/linuxqq-wayland-fix"
''
