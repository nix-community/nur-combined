{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation (_: {
  pname = "pleroma-buns";
  version = "0-unstable-2017-06-01";

  src = fetchurl {
    url = "https://finland.fi/wp-content/uploads/2017/06/finland-emojis.zip";
    hash = "sha256-LBN0eVqiPAMrLp7WjGlaBFK8uxP3fbkOiD4SM6ytLaU=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp 1000px/*.png $out

    runHook postInstall
  '';

  meta = {
    description = "The Finland emoji collection contains 56 tongue-in-cheek emotions, which were created to explain some hard-to-describe Finnish emotions, Finnish words and customs";
    homepage = "https://finland.fi/emoji/";
    license = lib.licenses.cc-by-nc-nd-40;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
})
