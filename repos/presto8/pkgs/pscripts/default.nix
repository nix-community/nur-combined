{
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation(finalAttrs: {
  pname = "pscripts";
  version = "2024-05-26";

  src = fetchFromGitHub {
    owner = "presto8";
    repo = "pscripts";
    rev = "5cce44b59eb8d4e790628c128448ab153dc39ab3";
    hash = "sha256-DIbHudQx85DXY5EC+lSFIBubO7VUuFhKTZyyg3FRHk8=";
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
