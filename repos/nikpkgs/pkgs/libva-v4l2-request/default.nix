{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, meson
, ninja
, pkg-config
, libva
, libdrm
, enableX11 ? stdenv.isLinux
, libX11
}:

stdenv.mkDerivation rec {
  pname = "libva-v4l2-request";
  version = "fix-kernel-6.6";

  outputs = [ "out" "dev" ];

  src = fetchFromGitHub {
    owner = "fenrig";
    repo = "libva-v4l2-request";
    rev = "${version}";
    hash = "sha256-R0qCR966PxmEFkSxm5GWHtpbYAWwIbAyvFgwa+7NRoQ=";
  };

  postPatch = ''
    substituteInPlace src/Makefile.am \
      --replace "/usr/lib/dri" "${placeholder "out"}/lib/dri"
  '';

  nativeBuildInputs = [ meson ninja pkg-config ];

  buildInputs = [ libva libdrm ]
    ++ lib.optional enableX11 libX11;

  meta = with lib; {
    description = "Intel Media Driver for VAAPI — Broadwell+ iGPUs";
    longDescription = ''
      The Intel Media Driver for VAAPI is a new VA-API (Video Acceleration API)
      user mode driver supporting hardware accelerated decoding, encoding, and
      video post processing for GEN based graphics hardware.
    '';
    homepage = "https://github.com/intel/media-driver";
    changelog = "https://github.com/intel/media-driver/releases/tag/intel-media-${version}";
    license = with licenses; [ bsd3 mit ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
