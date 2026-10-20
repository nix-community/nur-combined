{ lib, fetchFromGitHub, fetchurl, python313Packages }:
let
  pin = lib.importJSON ./source.json;
  # The upstream lock uses Typer's self-contained 0.27 release; nixpkgs still
  # provides 0.25. Keep the locked wheel rather than relaxing requirements.
  typer = python313Packages.buildPythonPackage {
    pname = "typer";
    inherit (pin.typer) version;
    format = "wheel";
    src = fetchurl {
      inherit (pin.typer) url hash;
    };
    dependencies = with python313Packages; [ annotated-doc rich shellingham ];
    pythonImportsCheck = [ "typer" ];
    meta.license = lib.licenses.mit;
  };
in
python313Packages.buildPythonApplication {
  pname = "edunet-cli";
  inherit (pin) version;
  pyproject = true;
  src = fetchFromGitHub { inherit (pin) owner repo rev hash; };
  build-system = [ python313Packages.hatchling ];
  dependencies = [ python313Packages.httpx python313Packages.rich typer ];
  nativeCheckInputs = [ python313Packages.pytestCheckHook ];
  pythonImportsCheck = [ "edunet_cli" ];
  postInstall = ''
    mkdir -p "$out/share/edunet/systemd"
    cp contrib/systemd/* "$out/share/edunet/systemd/"
    substituteInPlace "$out/share/edunet/systemd/edunet-check.service" \
      --replace-fail '%h/.local/bin/edunet' "$out/bin/edunet"
  '';
  meta = {
    description = "Campus ePortal login and logout CLI";
    homepage = "https://github.com/lihaoze123/hhu-edunet-cli";
    license = lib.licenses.mit;
    mainProgram = "edunet";
    platforms = lib.platforms.linux;
  };
}
