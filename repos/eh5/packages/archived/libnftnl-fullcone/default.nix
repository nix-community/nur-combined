{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  pkg-config,
  libmnl,
}:
stdenv.mkDerivation rec {
  version = "1.2.6";
  pname = "libnftnl";

  src = fetchurl {
    url = "https://netfilter.org/projects/${pname}/files/${pname}-${version}.tar.xz";
    hash = "sha256-zurqLNkhR9oZ8To1p/GkvCdn/4l+g45LR5z1S1nHd/Q=";
  };

  patches = [
    (fetchurl {
      url = "https://github.com/wongsyrone/lede-1/raw/6b320d085a860516a575590a5a23ba16a7bb9173/package/libs/libnftnl/patches/999-01-libnftnl-add-fullcone-expression-support.patch";
      sha256 = "sha256-il0TS51eQfzUfU6LzG9mmuFZvv5UpRF0YPY21jlsNQE=";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];
  buildInputs = [ libmnl ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "A userspace library providing a low-level netlink API to the in-kernel nf_tables subsystem (with fullcone support)";
    homepage = "https://netfilter.org/projects/libnftnl/";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [
      fpletz
      ajs124
    ];
  };
}
