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
, fetchpatch
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

  patches = [
    ./no-install-config.patch

    (fetchpatch {
      url = "https://github.com/LinusDierheimer/fastfetch" +
        "/commit/078cb6e5b713120eed879db77e77533f3f711c87.patch";
      hash = "sha256-PqFYrfOnebRQV8yEgLnxDBwLkfTOp2l0O1KdDmMKfZ0=";
    })
  ];

  cmakeFlags = [ "--no-warn-unused-cli" ];

  meta = with lib; {
    description = "Like neofetch, but much faster because written in C. ";
    homepage = "https://github.com/LinusDierheimer/${pname}";
    license = licenses.mit;
    maintainers = [ maintainers.vanilla ];
    platforms = [ "x86_64-linux" ];
  };
}
