{
  weechat-matrix = { python3Packages, fetchFromGitHub }: with python3Packages; buildPythonApplication rec {
    pname = "weechat-matrix";
    version = "2022-05-04";

    src = fetchFromGitHub {
      owner = "poljar";
      repo = "weechat-matrix";
      rev = "c2d2a52283f203e47ffd642c2a2845cbf5b7e980";
      sha256 = "sha256-s3krtqKhmvvALDDStIaJRdqqJoy7d7+/YCs4uG+hVrY=";
    };

    propagatedBuildInputs = [ requests matrix-nio ];

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
