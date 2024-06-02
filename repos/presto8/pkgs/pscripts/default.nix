{
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation(finalAttrs: rec {
  pname = "pscripts";
  version = "2024-06-02";

  src = fetchFromGitHub {
    owner = "presto8";
    repo = "pscripts";
    rev = "v${version}";
    hash = "sha256-tcBje0RFoz/h6IDcjFLMcC93Wcb9ADVHYfGDGT94waI=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mapfile -d $'\0' matches < <(find -maxdepth 1 -mindepth 1 -type d -printf "%f\0")
    for exe in "''${matches[@]}"; do
      install -D -m 755 "$exe"/"$exe" $out/bin/"$exe"
    done

    runHook postInstall
  '';
})
