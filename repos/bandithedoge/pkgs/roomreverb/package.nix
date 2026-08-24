{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "roomreverb";
  version = "1.4.1";
  src = fetchFromGitHub {
    owner = "cvde";
    repo = "RoomReverb";
    rev = "v${finalAttrs.version}";
    hash = "sha256-vo0AbbN0CoZXlwcVn1eVT5wVfdzx3ijqstpFWZ6kf+Y=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    juceCmakeHook
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Room Reverb is a mono/stereo to stereo algorithmic reverb audio plugin with many presets that lets you add reverberation to your recordings in your DAW";
    homepage = "https://github.com/cvde/RoomReverb";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
