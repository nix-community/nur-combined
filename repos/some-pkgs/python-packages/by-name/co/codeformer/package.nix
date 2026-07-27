{ lib
, fetchFromGitHub
, basicsr
, buildPythonPackage
, prefix-python-modules
, nixpkgs-pytools
, codeformer
, lpips
, opencv4
, setuptools
, torch
, wheel
}:

buildPythonPackage rec {
  pname = "codeformer";
  version = "unstable-2023-07-23";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sczhou";
    repo = "CodeFormer";
    rev = "8392d0334956108ab53d9439c4b9fc9c4af0d66d";
    hash = "sha256-yfQuscYnDwtv7RleWOvGZdzwDAGRawqPrVX9wZq12lY=";
  };

  postPatch = ''
    rm -r basicsr
    prefix-python-modules . --prefix $pname --exclude-glob 'web-demos*'
    python-rewrite-imports --path . --replace basicsr codeformer_basicsr
    cp ${./pyproject.toml} pyproject.toml
  '';

  nativeBuildInputs = [
    prefix-python-modules
    nixpkgs-pytools
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    passthru.basicsr
    opencv4
    torch
  ];

  pythonImportsCheck = [
    "codeformer.inference_codeformer"
  ];

  # codeformer vendors a patched copy of basicsr, but also vendors the setup.py
  # and some adds invalid imports there.
  passthru.basicsr = basicsr.overridePythonAttrs (oldAttrs: {
    pname = "codeformer-basicsr";

    # TODO: finalAttrs
    src = codeformer.src;

    # TODO: discard; we probably should just keep codeformer's basicsr in the
    # closure, and not the original
    prePatch = ''
      cd basicsr

      mv __init__.py init.py

      echo '__version__ = "0.0.0+aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"' >> version.py
      echo '__gitsha__ = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"' >> version.py
      echo >> README.md
      echo >> requirements.txt

      substituteInPlace \
        archs/__init__.py \
        models/__init__.py \
        data/__init__.py \
        --replace \
          "import_module(f'basicsr." \
          "import_module(f'codeformer_basicsr."

      substituteInPlace setup.py \
        --replace \
          "name='basicsr'" \
          "name='codeformer_basicsr'"
        

      prefix-python-modules . --prefix codeformer_basicsr  \
        --rename-external basicsr codeformer_basicsr "**"
      mv codeformer_basicsr/init.py codeformer_basicsr/__init__.py
      mv codeformer_basicsr/setup.py ./

      mkdir basicsr
      mv VERSION basicsr/
    '';
    nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [
      prefix-python-modules
    ];
    propagatedBuildInputs = oldAttrs.propagatedBuildInputs or [ ] ++ [
      lpips
    ];
    pythonImportsCheck = [ "codeformer_basicsr" ];
  });

  meta = with lib; {
    description = "NeurIPS 2022] Towards Robust Blind Face Restoration with Codebook Lookup Transformer";
    homepage = "https://github.com/sczhou/CodeFormer";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
    mainProgram = "codeformer";
    platforms = platforms.all;
  };
}
