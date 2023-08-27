{ lib
, buildPythonPackage
, bash
, python
, fetchFromGitHub
, easydict
, scipy
, torch
, torchvision
}:

buildPythonPackage rec {
  pname = "mask-face-gan";
  version = "unstable-2023-03-15";

  format = "other";

  src = fetchFromGitHub {
    owner = "MartinPernus";
    repo = "MaskFaceGAN";
    rev = "49b6c8a6e1f84b96123bacb3ce399a1ee432471c";
    hash = "sha256-oq2hBRAFTjhOdQHJP1TYUMwkqwPFuxyjGYUEb8u4Szs=";
  };

  postPatch =
    let
      cwdModules = [
        "loss_function_helpers"
        "lpips"
        "model_module"
        "models"
        "trainer"
        "utils"
      ];
      reCwdModules = builtins.concatStringsSep "\\|" cwdModules;
    in
    ''
      find -iname '*.py' -exec sed -i 's/from \(${reCwdModules}\) import/from MaskFaceGAN.\1 import/' '{}' \;
      find -iname '*.py' -exec sed -i 's/^\(\s*\)import \(${reCwdModules}\)/\1import MaskFaceGAN.\2/' '{}' \;
      substituteInPlace download.sh --replace "bin/bash" "${lib.getExe bash}"
    '';

  propagatedBuildInputs = [
    easydict
    scipy
    torch
    torchvision
  ];

  installPhase =
    let
      moduleDir = "$out/${python.sitePackages}/MaskFaceGAN";
    in
    ''
      mkdir -p "${moduleDir}" $out/share/${pname} $out/bin
      install -t "${moduleDir}" *.py
      cp -rf lpips/ models/ "${moduleDir}"/
      install -t $out/share/${pname}/ -m 444 config.yml
      install download.sh $out/share/${pname}/download.sh
    '';

  pythonImportsCheck = [
    # Runs ninja:
    # "MaskFaceGAN.model_module"
  ];

  meta = with lib; {
    broken = true;
    description = "High resolution fine-grained face editing";
    homepage = "https://github.com/MartinPernus/MaskFaceGAN";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
