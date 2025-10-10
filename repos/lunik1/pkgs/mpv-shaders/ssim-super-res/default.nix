{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "ssim-super-res";
  version = "unstable-2022-02-07";

  src = fetchurl {
    url = "https://gist.githubusercontent.com/igv/2364ffa6e81540f29cb7ab4c9bc05b6b/raw/15d93440d0a24fc4b8770070be6a9fa2af6f200b/SSimSuperRes.glsl";
    sha256 = "sha256-qLJxFYQMYARSUEEbN14BiAACFyWK13butRckyXgVRg8=";
  };

  dontUnpack = true;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/share/ssim-super-res/SSimSuperRes.glsl

    runHook postInstall
  '';

  meta = with lib; {
    description = "SSimSuperRes by Shiandow";
    homepage = "https://gist.github.com/igv/2364ffa6e81540f29cb7ab4c9bc05b6b";
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [ lunik1 ];
    platforms = platforms.all;
  };
}
