{
  lib,
  stdenv,
  fetchurl,
  p7zip,
  pname-suffix ? "",
  desc-suffix ? "",
  fonts ? (import ./lists.nix).default
}:
let
  file-lists = (import ./fonts.nix).files;
  ttfs = lib.concatLists (lib.forEach fonts (f: file-lists.${f}));
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ttf-ms-win11${pname-suffix}";
  version = "10.0.26100.1742";  # Windows 11, version 24H2

  src = fetchurl {
    url = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso";
    hash = "sha256-dVqQ1D6CanS54ZMqNHiLiY4CgnJDm3d+VZPe6NU2Iq4=";
  };

  nativeBuildInputs = [
    p7zip
  ];

  unpackPhase = ''
    runHook preUnpack

    7z e $src -o. 'sources/install.wim'
    7z e install.wim -o. 'Windows/Fonts/*'
    rm install.wim

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts
  '' +
  (lib.concatLines (lib.forEach ttfs (f: "cp ${f} $out/share/fonts"))) +
  ''
    runHook postInstall
  '';

  meta = {
    description = "Microsoft Windows 11 TrueType fonts${desc-suffix}";
    homepage = "https://learn.microsoft.com/en-us/typography/";
    maintainers = with lib.maintainers; [ ivyfanchiang ];
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
})
