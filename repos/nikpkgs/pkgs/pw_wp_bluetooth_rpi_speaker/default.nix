{
  fetchFromGitHub,
  lib,
  python3Packages,
  wrapGAppsHook3
}:
python3Packages.buildPythonApplication rec {
  pname = "pw_wp_bluetooth_rpi_speaker";
  version = "master";
  pyproject = false;
  owner = "fdanis-oss";

  src = fetchFromGitHub {
    inherit owner;
    repo   = pname;
    rev    = "57569e46b506782e503129f791809b2aae2b0ea6";
    hash   = "sha256-zY3gVIYTqVWJe6Slx/vYSXukGPFJxw8XgThmWJHiano=";
  };

  propagatedBuildInputs = (with python3Packages; [
    pygobject3
    dbus-python
  ]);

  nativeBuildInputs = [
    wrapGAppsHook3
  ];

  dontUnpack = true;
  installPhase = ''
    install -Dm755 $src/speaker-agent.py "$out/bin/${pname}";
  '';

  meta = with lib; {
    description = "Using a Raspberry Pi as a Bluetooth® speaker with PipeWire";
    homepage = "https://github.com/${owner}/${pname}";
    license = licenses.lgpl21;
  };
}
