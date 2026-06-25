{ lib, stdenvNoCC, fetchzip, ... }:
let
  inherit (lib)
    maintainers
    ;

  version = "26100.1742.240906-0331";

  license = {
    shortName = "microsoft-software-license";
    fullName = "Microsoft Software License Terms";
    url = "https://support.microsoft.com/en-us/windows/microsoft-software-license-terms-e26eedad-97a2-5250-2670-aad156b654bd";
    free = false;
    redistributable = false;
  };

  src = fetchzip {
    url = "https://github.com/DzmingLi/nur-packages/releases/download/windows-fonts-${version}/windows-fonts-${version}.tar.gz";
    hash = "sha256-gOkhXIyFefeGQZ8PJNINVtkE2gcvX4pHmQPTErNc9uM=";
  };

  meta = {
    inherit
      license
      ;

    description = "Windows fonts distributed by Microsoft Microsoft Corporation Inc.";
    homepage = "https://learn.microsoft.com/en-us/typography/fonts/font-faq";
    maintainers = with maintainers; [ brsvh ];
    redistributable = false;
  };
in
stdenvNoCC.mkDerivation {
  inherit
    meta
    src
    version
    ;

  pname = "windows-fonts";

  preferLocalBuild = true;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    cp -a ${src}/*.ttf $out/share/fonts/truetype/
    cp -a ${src}/*.ttc $out/share/fonts/truetype/

    runHook postInstall
  '';
}
