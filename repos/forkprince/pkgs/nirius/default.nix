{
  fetchFromSourcehut,
  rustPlatform,
  lib,
  ...
}:
rustPlatform.buildRustPackage rec {
  pname = "nirius";
  version = "0.3.1";

  src = fetchFromSourcehut {
    owner = "~tsdh";
    repo = "nirius";
    rev = "${pname}-${version}";
    hash = "sha256-PzsIEksOp8ZO3f2hGcZ+8X9SvlXKI2oRdi7Nelmlyxk=";
  };

  cargoHash = "sha256-DPeAgwaVrzuzG2ufNuO16VtLArQeBE6no9uQbLSqiHQ=";

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
    maintainers = ["Prinky"];
    platforms = lib.platforms.linux;
    mainProgram = "nirius";
    sourceProvenance = with lib.sourceTypes; [fromSource];
  };
}
