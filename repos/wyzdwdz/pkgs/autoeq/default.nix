{
  lib,
  python311Packages,
  fetchFromGitHub,
}:

python311Packages.buildPythonApplication {
  pname = "autoeq";
  version = "unstable-2025-07-20";

  src = fetchFromGitHub {
    owner = "jaakkopasanen";
    repo = "AutoEq";
    rev = "7ae0f56d53074872b028649617a22bbb4232feb7";
    hash = "sha256-/kj5ITqtaEWtcZkmB5DEIfj44otXKXYBE7ArV++YLkM=";
  };

  pyproject = true;

  nativeBuildInputs = with python311Packages; [
    pythonRelaxDepsHook
  ];

  pythonRelaxDeps = true;

  build-system = with python311Packages; [ hatchling ];

  dependencies = with python311Packages; [
    pillow
    matplotlib
    scipy
    numpy
    tabulate
    soundfile
    pyyaml
    tqdm
  ];

  postInstall = ''
    mkdir -p $out/bin

    cat <<'EOF' > $out/bin/autoeq
    #!/usr/bin/env python
    import sys
    import runpy
    if __name__ == '__main__':
        sys.argv[0] = 'autoeq'
        runpy.run_module('autoeq', run_name='__main__')
    EOF

    chmod +x $out/bin/autoeq
  '';

  meta = with lib; {
    description = "Automatic headphone equalization from frequency responses";
    homepage = "https://github.com/jaakkopasanen/AutoEq";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "autoeq";
    broken = false;
  };
}
