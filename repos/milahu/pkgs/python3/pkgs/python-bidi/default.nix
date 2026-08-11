{ lib
, python3
, fetchFromGitHub
, cargo
, rustPlatform
, rustc
, setuptools
, wheel
, six
#, version ? "unstable-2024-03-16"
, version ? "0.4.0"
}:

python3.pkgs.buildPythonApplication rec {
  pname = "python-bidi";
  inherit version;
  pyproject = true;

  src =
  if version == "unstable-2024-03-16" then
  fetchFromGitHub {
    owner = "MeirKriheli";
    repo = "python-bidi";
    rev = "76b46194c220424918f71ca32838062baf151450";
    hash = "sha256-W1l9JC/ZwsvheFII4D7z6SeDo/ErhZ5SeQ7knQ5GzCI=";
  }
  else
  if version == "0.4.0" then
  fetchFromGitHub {
    owner = "MeirKriheli";
    repo = "python-bidi";
    rev = "v${version}";
    hash = "sha256-OpPXmEgD8zKBT5xBao3CJCVTucmkqcaerxcWeMblp3Q=";
  }
  else
  throw "unknown version: ${builtins.toString version}"
  ;

  cargoDeps =
  if version == "unstable-2024-03-16" then
  rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-BJwqIoRJY3+VeOkn4hgFKBYaHPv9LTVdj8/yFNjhE6E=";
  }
  else
  null
  ;

  nativeBuildInputs =
  if version == "unstable-2024-03-16" then
  [
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ]
  else
  [
    setuptools
    wheel
  ]
  ;

  propagatedBuildInputs =
  if version == "unstable-2024-03-16" then
  [ ]
  else
  [
    six
  ]
  ;

  passthru.optional-dependencies = with python3.pkgs; {
    dev = [
      pytest
    ];
  };

  pythonImportsCheck = [ "bidi" ];

  meta = with lib; {
    description = "BIDI  algorithm related functions";
    homepage = "https://github.com/MeirKriheli/python-bidi";
    changelog = "https://github.com/MeirKriheli/python-bidi/blob/${src.rev}/CHANGELOG.rst";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "pybidi";
  };
}
