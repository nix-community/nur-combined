{
  lib,
  rustPlatform,
  fetchFromSourcehut,
  pkg-config,
  pulseaudio,
  dbus,
  alsa-lib,
  fontconfig,
  libxkbcommon,
  wayland,
}:

let
  rpathLibs = [
    fontconfig
    dbus
    alsa-lib
    pulseaudio
    libxkbcommon
  ];
in

rustPlatform.buildRustPackage rec {
  pname = "wldash";
  version = "master";

  src = fetchFromSourcehut {
    owner = "~kennylevinsen";
    repo = pname;
    rev = "70e53c1246e0d35b78c5db5146d0da6af716c293";
    sha256 = "sha256-TZDYO8YoUA1FOlmTiT6oYPx8+29NtQCeVCCJ8UOPJwE=";
  };

  cargoHash = "sha256-qvTaCasr1uKWynKN1rYIp9cViae24KGM78hgaSwNXRA=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = rpathLibs;

  strictDeps = true;

  postInstall = ''
    # Strip executable and set RPATH
    # Stolen from https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/applications/terminal-emulators/alacritty>
    strip -s $out/bin/wldash
    patchelf --set-rpath "${lib.makeLibraryPath rpathLibs}" $out/bin/wldash
  '';

  dontPatchELF = true;

  meta = with lib; {
    description = "A dashboard/launcher/control-panel thing for Wayland.";
    homepage = "https://git.sr.ht/~kennylevinsen/wldash";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.polykernel ];
    platforms = platforms.linux;
  };
}
