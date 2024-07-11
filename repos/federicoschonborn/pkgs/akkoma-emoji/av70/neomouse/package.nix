{
  lib,
  stdenv,
  fetchFromGitea,
}:

stdenv.mkDerivation rec {
  pname = "av70-neomouse";
  version = "0-unstable-2024-07-02";

  src = fetchFromGitea {
    domain = "git.gay";
    owner = "av70";
    repo = "neomouse";
    rev = "924d766d7c03210c29789a44b364cb546a8abaed";
    hash = "sha256-C5XaMYEVPZHxBqrbjdcmm/LoBP+uzSutnS7r7uwB5uY=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    for dir in 256x/neomouse{,-additional} spinny-mouse/render; do
      cp $(find $dir -name "*.png" -or -name "*.gif") $out
    done

    runHook postInstall
  '';

  meta = {
    description = "There are mice";
    homepage = "https://git.gay/av70/neomouse";
    license = lib.licenses.cc-by-nc-sa-40;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
