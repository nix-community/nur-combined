{
  lib,
  stdenvNoCC,
  fetchurl,
  p7zip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "windows-fonts";
  version = "26200.6584.250915-1905";

  src = fetchurl {
    # https://aka.ms/Win11E-ISO-25H2-zh-cn
    url = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26200.6584.250915-1905.25h2_ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_zh-cn.iso";
    hash = "sha256-e0rIc5G2WfdyQiloK2QiViiaHABQQFYknw8SApFX09I=";
  };
  outputHashMode = "recursive";
  outputHash = "sha256-HPUb9txrWmHzx3bU/3bnPO59vlXJImBK/s/G74odcl8=";

  preferLocalBuild = true;

  nativeBuildInputs = [ p7zip ];

  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack

    7z x $src sources/install.wim

    7z e sources/install.wim Windows/{Fonts/"*".{ttf,ttc},System32/Licenses/neutral/"*"/"*"/license.rtf} -ofonts/

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm444 fonts/* -t $out/share/fonts/truetype/

    runHook postInstall
  '';

  passthru._notCI = true;

  meta = {
    description = "Windows fonts distributed by Microsoft Microsoft Corporation Inc.";
    homepage = "https://learn.microsoft.com/en-us/typography/fonts/font-faq";
    longDescription = ''
      Windows fonts are proprietary software distributed by Microsoft Corporation Inc.

      This package does not give you any rights to any of its included
      fonts.
    '';
    license = {
      shortName = "microsoft-software-license";
      fullName = "Microsoft Software License Terms";
      url = "https://support.microsoft.com/en-us/windows/microsoft-software-license-terms-e26eedad-97a2-5250-2670-aad156b654bd";
      free = false;
      redistributable = false;
    };
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.platforms.all;
  };
})
