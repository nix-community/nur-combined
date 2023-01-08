{ clangStdenv
, fetchgit
, cmake
, pkg-config
, pciutils
, vulkan-loader
, libffi
, wayland
, xorg
, glib
, pcre2
, util-linux
, libselinux
, libsepol
, pcre
, dconf
, dbus
, xfce
, sqlite
, zstd
, rpm
, imagemagick
, imagemagick6
, chafa
, libglvnd
, mesa
, ocl-icd
, opencl-headers
, cjson
, lib
}:

clangStdenv.mkDerivation rec {
  pname = "fastfetch";
  version = "1.8.2";

  src = fetchgit {
    url = "https://github.com/LinusDierheimer/${pname}";
    rev = "${version}";
    hash = "sha256-Sh31zKkjcNRD5KyNUzbTHRitC/7e2TYKKtpTohGhTQc=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ pciutils ] ++ [ vulkan-loader libffi ] ++ [ wayland ]
    ++ (with xorg; [ libxcb libXau libXdmcp ]) ++ (with xorg; [ libXrandr libXext ])
    ++ [ glib ] ++ [ pcre2 util-linux libselinux libsepol pcre ] ++ [ dconf dbus xfce.xfconf ]
    ++ [ sqlite zstd ] ++ [ rpm imagemagick imagemagick6 chafa libglvnd mesa ]
    ++ [ ocl-icd opencl-headers cjson ];

  NIX_CFLAGS_COMPILE = [
    "-Wno-macro-redefined"
    "-Wno-implicit-int-float-conversion"
  ];

  # https://github.com/LinusDierheimer/fastfetch/blob/1.8.2/CMakeLists.txt
  cmakeFlags = [ "-DTARGET_DIR_ROOT=$out" "--no-warn-unused-cli" ];

  meta = with lib; {
    description = "Like neofetch, but much faster because written in C. ";
    homepage = "https://github.com/LinusDierheimer/${pname}";
    license = licenses.mit;
    maintainers = [ maintainers.vanilla ];
    platforms = [ "x86_64-linux" ];
  };
}
