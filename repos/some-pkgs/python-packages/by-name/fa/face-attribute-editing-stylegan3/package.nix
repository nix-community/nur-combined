{ lib
, buildPythonPackage
, python
, fetchFromGitHub
, torch
, openai-clip
, moduleName ? "fed_stylegan3"
}:

let
  moduleDir = if moduleName != null then "$out/${python.sitePackages}/${moduleName}" else "$out/${python.sitePackages}";
in

buildPythonPackage rec {
  pname = "face-attribute-editing-stylegan3";
  version = "unstable-2022-10-21";
  format = "other";

  src = fetchFromGitHub {
    owner = "MingtaoGuo";
    repo = "Face-Attribute-Editing-StyleGAN3";
    rev = "d3da989c188b37d7e36cf13e3f9bd8f4ab78ee21";
    hash = "sha256-sgc4ZOIxSmr+vOP17bo3a6qG2lmyUDW1onm/XT2t/Oc=";
  };

  postPatch =
    let
      cwdModules = [
        "arcface"
        "Dataset"
        "Discriminator"
        "dnnlib"
        "e4e_inference"
        "e4e_train"
        "ganspace"
        "legacy"
        "lpips"
        "pspEncoder"
        "torch_utils"
        "training"
        "vgg"
      ];
      reCwdModules = builtins.concatStringsSep "\\|" cwdModules;
      prefix = moduleName;
    in
    lib.optionalString (moduleName != null) ''
      find -iname '*.py' -exec sed -i 's/^\(\s*\)from \(${reCwdModules}\) import/\1from ${prefix}.\2 import/' '{}' \;
      find -iname '*.py' -exec sed -i 's/^\(\s*\)import \(${reCwdModules}\)/\1import ${prefix}.\2 as \2/' '{}' \;
    '';

  propagatedBuildInputs = [
    torch
    openai-clip
  ];

  installPhase = ''
    mkdir -p "${moduleDir}" $out/share/${pname} $out/bin
    # install train.py $out/bin/${pname}-train.py
    install -t "${moduleDir}" *.py
    cp -rf dnnlib/ lpips/ torch_utils/ training/ "${moduleDir}"/
  '';

  meta = with lib; {
    broken = true;
    description = "Face editing by e4e, text2stylegan,interfacegan,ganspace";
    homepage = "https://github.com/MingtaoGuo/Face-Attribute-Editing-StyleGAN3";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
