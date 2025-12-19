{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  libva,
  libdrm,
  enableX11 ? stdenv.isLinux,
  libX11,
}:

stdenv.mkDerivation rec {
  pname = "libva-v4l2-request";
  version = "fix-kernel-6.6";

  outputs = [
    "out"
    "dev"
  ];

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

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libva
    libdrm
  ] ++ lib.optional enableX11 libX11;

  meta = with lib; {
    description = "LibVA implementation for the Linux Video4Linux2 Request API";
    longDescription = ''
      This is a fork that fixes the original bootlin's repository so that it actually compiles on modern Linux machines.

      In order to use this you'll have to use the folllowing nixOS configuration:
      {
        hardware.opengl = {
          enable = true;
          extraPackages = [ this_package ];
        };
        environment.sessionVariables = {
          LIBVA_DRIVER_NAME = "v4l2_request";
          LIBVA_V4L2_REQUEST_MEDIA_PATH = "/dev/video0"; # change this to point to your actual V4L2 decode/encode device
        };
      }
    '';
    homepage = "https://github.com/fenrig/libva-v4l2-request/tree/${version}";
    changelog = "https://github.com/fenrig/libva-v4l2-request/commits/${version}";
    license = with licenses; [
      lgpl21
      mit
    ];
    platforms = platforms.linux;
  };
}
