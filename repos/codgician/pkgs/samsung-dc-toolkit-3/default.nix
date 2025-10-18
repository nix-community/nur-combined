{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "samsung-dc-toolkit";
  version = "3.0";

  src = fetchurl {
    url = "https://download.semiconductor.samsung.com/resources/software-resources/Samsung_SSD_DC_Toolkit_Brand_for_Linux_V${finalAttrs.version}";
    hash = "sha256-Hdcy9VHgU8hDE2E1u7puN/fkh5wjchDl7Ssrtyu8lig=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp $src $out/bin/Samsung_SSD_DC_Toolkit_V''${version}
    chmod +x $out/bin/Samsung_SSD_DC_Toolkit_V''${version}

    runHook postInstall
  '';

  meta = {
    description = "Samsung DC Toolkit is designed to help users with easy-to-use disk management and diagnostic features for server
and data center usage.";
    homepage = "https://semiconductor.samsung.com/consumer-storage/support/tools/";
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ codgician ];
    mainProgram = "Samsung_SSD_DC_Toolkit_V${finalAttrs.version}";
  };
})
