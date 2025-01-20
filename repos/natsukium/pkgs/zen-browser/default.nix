{
  source,
  lib,
  stdenvNoCC,
  undmg,
}:

stdenvNoCC.mkDerivation {
  inherit (source) pname version src;

  nativeBuildInputs = [ undmg ];

  preferLocalBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r . $out

    runHook postInstall
  '';

  meta = {
    description = "Privacy-focused browser that blocks trackers; ads; and other unwanted content while offering the best browsing experience!";
    homepage = "https://github.com/zen-browser/desktop";
    license = lib.licenses.mpl20;
    platforms = [ "aarch64-darwin" ];
  };
}
