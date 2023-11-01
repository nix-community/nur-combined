{
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation(finalAttrs: {
  pname = "pscripts";
  version = "2023-10-29";

  src = fetchFromGitHub {
    owner = "presto8";
    repo = "pscripts";
    rev = "dd2fb825a243535b5827e0412604d75bcd485770";
    hash = "sha256-ggFrd+tDQ6DL4CEnWDDSBEzWwkmlwwtpa84DbsNyQYc=";
  };

  installPhase = ''
    runHook preInstall

    for exe in pnix pdrives pmove; do
      install -D -m 755 "$exe"/"$exe" $out/bin/"$exe"
    done

    runHook postInstall
  '';
})
