{
  lib,
  fetchFromGitHub,
  tcl,
  tcllib,
  tclreadline,
  wakatime-cli,
  expect,
}:

tcl.mkTclDerivation rec {
  name = "tcl-prompt";
  src = fetchFromGitHub {
    owner = "wakatime";
    repo = name;
    rev = "f11e245093d86967d5dbc10e110f8b0fbbcc4b8f";
    hash = "sha256-R55o6Ezj2N2F8I3XObysJQN7dF+V0iopyU20Nz4Ln8I=";
  };

  dontConfigure = true;
  dontBuild = true;

  buildInputs = [
    tclreadline
    tcllib
    expect
    wakatime-cli
  ];
  installPhase = ''
    install -d $out/lib
    cp -r modules $out/lib/tcl-prompt
    cp -r bin $out
  '';

  meta = with lib; {
    homepage = "https://github.com/wakatime/tcl-prompt";
    description = "Tcl plugin for powerlevel10k style prompt and WakaTime time tracking";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
