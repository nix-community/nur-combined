{
  weechat-matrix = { python3Packages, fetchFromGitHub }: with python3Packages; buildPythonApplication rec {
    pname = "weechat-matrix";
    version = "2022-09-08";

    src = fetchFromGitHub {
      owner = "poljar";
      repo = "weechat-matrix";
      rev = "989708d1fa8fcee6d5bbb4c19a7d66f14d84fd5b";
      sha256 = "sha256-+SDjtaDm3H0T4xboqf+eycnto7z1tAkkbqRY29I4EaA=";
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
