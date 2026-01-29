{
  fetchurl,
  lib,
  p7zip,
  stdenvNoCC,
  ...
}:
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

  src = fetchurl {
    hash = "sha256-FqD9lfDYTlTiYNnxKbOePTFg17KU2YbduzqZs4KNHGI=";
    url = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_zh-cn.iso";
  };

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

  buildInputs = nativeBuildInputs;

  nativeBuildInputs = [
    p7zip
  ];

  unpackPhase = ''
    runHook preUnpack

    tempdir=$(mktemp -d)

    7z x $src -o$tempdir

    mkdir fonts

    7z e $tempdir/sources/install.wim Windows/{Fonts/"*".{ttf,ttc},System32/Licenses/neutral/"*"/"*"/license.rtf} -ofonts

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    find fonts -type f \( -iname "*.ttf" -o -iname "*.ttc" \) -print0 \
      | xargs -0 install -Dm444 -t $out/share/fonts/truetype/

    runHook postInstall
  '';
}
