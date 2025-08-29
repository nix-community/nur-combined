{
  sources,
  python312Packages,
  lib,
  testers,
  ly2video,
}:

# the pipes module is removed in python 3.13
python312Packages.buildPythonPackage {
  inherit (sources.ly2video) pname version src;

  pyproject = true;
  build-system = with python312Packages; [ setuptools ];

  propagatedBuildInputs = with python312Packages; [
    setuptools
    pillow
    pexpect
    mido
  ];

  passthru.tests.help = testers.runCommand {
    name = "ly2video-help";
    script = ''
      ly2video --help
      touch $out
    '';
    nativeBuildInputs = [ ly2video ];
  };

  meta = with lib; {
    homepage = "https://github.com/aspiers/ly2video";
    description = "Generating videos from LilyPond projects";
    maintainers = with maintainers; [ yinfeng ];
    license = licenses.gpl3;
  };
}
