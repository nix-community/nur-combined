{
  fetchFromSourcehut,
  rustPlatform,
  lib,
  ...
}:
rustPlatform.buildRustPackage rec {
  pname = "nirius";
  version = "0.7.1";

  src = fetchFromSourcehut {
    owner = "~tsdh";
    repo = "nirius";
    rev = "${pname}-${version}";
    hash = "sha256-+OPJODiZs3+d3W8vnLCbza4axgIu6WBeC2j+JLN/Zgg=";
  };

  cargoHash = "sha256-lxyChCuo6ZtZ6Sd50xn2KyY7JTf3KCobZnI0AsM3CUE=";

  cargoBuildFlags = ["--all-features"];

  installPhase = ''
    runHook preInstall

    for bin in ${pname} ${pname}d; do
      path=$(find target -type f -name "$bin" -executable | head -n1)
      if [ -z "$path" ]; then
        echo "Error: Binary $bin not found in target/"
        exit 1
      fi
      echo "Installing $bin from $path"
      install -Dm755 "$path" "$out/bin/$bin"
    done

    runHook postInstall
  '';

  meta = {
    description = "Utility commands for the niri wayland compositor";
    homepage = "https://sr.ht/~tsdh/nirius/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.linux;
    mainProgram = "nirius";
    sourceProvenance = [lib.sourceTypes.fromSource];
  };
}
