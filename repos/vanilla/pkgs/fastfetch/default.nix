{ stdenv, fetchgit, cmake, pkg-config, pciutils, vulkan-loader, vulkan-headers, xorg, wayland, libffi, glib, pcre, libuuid, libselinux, libsepol, dconf, xfce, rpm, zstd, lib, ... }:
stdenv.mkDerivation rec {
  pname = "fastfetch";
  version = "79bec5c";

  src = fetchgit {
    url = "https://github.com/LinusDierheimer/${pname}";
    rev = "${version}2204ab9d4e166c4c58ccf67410d771253";
    hash = "sha256-1SyR7xtg52mphpvxEMRGeIIKa8VfRnQbIjaB/x+BPrw=";
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ pciutils vulkan-loader vulkan-headers ]
    ++ (with xorg; [ libX11 libXau libXdmcp libXrandr libXext ])
    ++ [ wayland libffi glib pcre libuuid libselinux libsepol ]
    ++ [ dconf xfce.xfconf rpm zstd ];

  # https://github.com/LinusDierheimer/fastfetch/blob/${src.rev}/CMakeLists.txt#L18
  patches = [ ./no-execute-git.patch ];

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=fastfetch-git
  installPhase = ''
    install -D fastfetch $out/bin/fastfetch
    install -D flashfetch $out/bin/flashfetch
    install -D ${src}/completions/bash $out/share/bash-completion/completions/fastfetch

    install -Dd $out/share/fastfetch/presets/
    for file in ${src}/presets/*; do
      install -D $file $out/share/fastfetch/presets/
    done
  '';

  meta = with lib; {
    description = "Like neofetch, but much faster because written in c. Only Linux. ";
    homepage = "https://github.com/LinusDierheimer/${pname}";
    license = licenses.mit;
    maintainers = [ maintainers.vanilla ];
    platforms = [ "x86_64-linux" ];
  };
}
