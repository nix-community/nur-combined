{
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation(finalAttrs: {
  pname = "pscripts";
  version = "2024-05-25T08:16";

  src = fetchFromGitHub {
    owner = "presto8";
    repo = "pscripts";
    rev = "74a664da32b18364e60c06a531ac1f2ceb6a7222";
    hash = "sha256-t1o25Fp6PSSX+bxVOjKdyWlFFdycX0bc2ZAvc5d5GZE=";
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
