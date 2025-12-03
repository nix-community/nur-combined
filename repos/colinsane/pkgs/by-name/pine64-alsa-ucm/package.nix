{
  fetchFromGitLab,
  gnused,
  lib,
  stdenvNoCC,
  withVoiceCall ? false,  #< enable the "Voice Call" audio variants, which frequently don't work and idk what they're *supposed* to do
}:
stdenvNoCC.mkDerivation {
  pname = "pine64-alsa-ucm";
  version = "unstable-2021-12-10";

  src = fetchFromGitLab {
    owner = "pine64-org";
    repo = "pine64-alsa-ucm";
    rev = "ec0ef36b8b897ed1ae6bb0d0de13d5776f5d3659";
    hash = "sha256-nsZXBB5VpF0YpfIS+/SSHMlPXSyIGLZSOkovjag8ifU=";
  };

  nativeBuildInputs = lib.optionals (!withVoiceCall) [
    gnused
  ];

  buildPhase = lib.optionalString (!withVoiceCall) ''
    sed -e '/SectionUseCase."Voice Call"/,+3d' -i ucm2/PinePhone/PinePhone.conf
    rm ucm2/PinePhone/VoiceCall.conf

    sed -e '/SectionUseCase."Voice Call"/,+3d' -i ucm2/PinePhonePro/PinePhonePro.conf
    rm ucm2/PinePhonePro/VoiceCall.conf
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/alsa/ucm2/{Allwinner/A64,Rockchip/rk3399/}
    cp -R ucm2/PinePhone $out/share/alsa/ucm2/Allwinner/A64/
    cp -R ucm2/PinePhonePro $out/share/alsa/ucm2/Rockchip/rk3399/

    mkdir -p $out/share/alsa/ucm2/conf.d/simple-card
    ln -s ../../Rockchip/rk3399/PinePhonePro/PinePhonePro.conf $out/share/alsa/ucm2/conf.d/simple-card/PinePhonePro.conf
    ln -s ../../Allwinner/A64/PinePhone/PinePhone.conf $out/share/alsa/ucm2/conf.d/simple-card/PinePhone.conf

    # XXX(2025-09-03): if booted via systemd-boot, the card will be named differently but otherwise function equivalently.
    # this is because, if DMI (via EFI) is available, the kernel uses Vendor + Product Name fields to assign the card a long_name,
    # instead of the device-tree fields.
    # there seems no easy way to change that on the kernel side, nor to configure ALSA UCM to prefer the card short name.
    # TODO: consider other ways to configure the card *besides* UCM:
    # - smarter in-kernel driver/configs?
    # - pipewire / pulseaudio card profiles?
    # - particularly, expose the card on the kernel side in such a way that the generic pipewire profiles can configure it.
    ln -s PinePhonePro.conf $out/share/alsa/ucm2/conf.d/simple-card/pine64-Pine64PinePhonePro-.conf

    runHook postInstall
  '';

  # paths in alsa are always relative to the root ucm;
  # since we moved stuff around, we have to fix it:
  fixupPhase = ''
    runHook preFixup

    substituteInPlace $out/share/alsa/ucm2/Allwinner/A64/PinePhone/PinePhone.conf \
      --replace-fail '"HiFi.conf"' '"/Allwinner/A64/PinePhone/HiFi.conf"' \
      ${lib.optionalString withVoiceCall ''--replace-fail '"VoiceCall.conf"' '"/Allwinner/A64/PinePhone/VoiceCall.conf"' ''}

    substituteInPlace $out/share/alsa/ucm2/Rockchip/rk3399/PinePhonePro/PinePhonePro.conf \
      --replace-fail '"HiFi.conf"' '"/Rockchip/rk3399/PinePhonePro/HiFi.conf"' \
      ${lib.optionalString withVoiceCall ''--replace-fail '"VoiceCall.conf"' '"/Rockchip/rk3399/PinePhonePro/VoiceCall.conf"' ''}

    runHook postFixup
  '';
}
