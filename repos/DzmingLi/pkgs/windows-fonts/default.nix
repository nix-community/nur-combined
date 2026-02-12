{ lib, stdenvNoCC, ... }:
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

  src = ./files;

  meta = {
    inherit
      license
      ;

    description = "Windows fonts distributed by Microsoft Microsoft Corporation Inc.";
    homepage = "https://learn.microsoft.com/en-us/typography/fonts/font-faq";

    longDescription = ''
      Windows fonts are proprietary software distributed by Microsoft Corporation Inc.

      This package does not give you any rights to any of its included
      fonts.
    '';

    maintainers = with maintainers; [ brsvh ];
    redistributable = false;
  };
in
stdenvNoCC.mkDerivation rec {
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
    cp -a ${src}/truetype/. $out/share/fonts/truetype/

    runHook postInstall
  '';
}
