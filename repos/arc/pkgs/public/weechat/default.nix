{
  weechat-matrix = { python3Packages, fetchFromGitHub }: with python3Packages; buildPythonApplication rec {
    pname = "weechat-matrix";
    version = "2021-06-06";

    src = fetchFromGitHub {
      owner = "poljar";
      repo = "weechat-matrix";
      rev = "d67821ae50dbfc86e9aa03709aa2a752aee705f6";
      sha256 = "01zisps5fx4i3vkrir8k04arcqf0n5i84a4nf0m9c2k48312dzf6";
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
