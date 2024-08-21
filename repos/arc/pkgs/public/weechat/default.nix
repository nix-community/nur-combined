{
  weechat-matrix = { python3Packages, fetchFromGitHub }: with python3Packages; buildPythonApplication rec {
    inherit (weechat-matrix) pname version src;

    propagatedBuildInputs = [ requests weechat-matrix.matrix-nio or matrix-nio ];

    doCheck = false;

    passAsFile = [ "setup" ];
    setup = ''
      from setuptools import setup

      setup(
        name='@pname@',
        version='@version@',
        install_requires=['requests', 'matrix-nio'],
        packages=[],
        scripts=['contrib/matrix_decrypt.py'],
      )
    '';

    postPatch = ''
      substituteAll $setupPath setup.py
    '';

    postInstall = ''
      mv $out/bin/matrix_decrypt{.py,}

      install -D main.py $out/share/weechat/matrix.py
    '';

    passthru = {
      scripts = [ "weechat/matrix.py" ];
      pythonPath = weechat-matrix;
    };
  };
}
