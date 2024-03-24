{ lib
, buildPythonPackage
, fetchFromGitLab
, flit-core
, libpulseaudio
, psutil
, pulseaudio
}:

buildPythonPackage rec {
  pname = "pa-dlna";
  version = "0.7";
  format = "pyproject";

  src = fetchFromGitLab {
    owner = "xdegaye";
    repo = "pa-dlna";
    rev = "v${version}";
    hash = "sha256-tc3AjxTMeLH82d8R95xsqLeAH1t/orW7c9DGjBwDWaU=";
  };

  postPatch = ''
    substituteInPlace pa_dlna/libpulse/libpulse.py --replace-fail \
      "path = find_library('pulse')" \
      "path = '${lib.getLib libpulseaudio}/lib/libpulse.so'"
  '';

  nativeBuildInputs = [
    flit-core
  ];

  propagatedBuildInputs = [
    psutil
    # `pa-dlna` shells out to `pa-rec` at runtime.
    pulseaudio
    # optional runtime binaries in case the DLNA renderer does not support PCM L16:
    # ffmpeg flac lame
  ];

  pythonImportsCheck = [
    "pa_dlna"
  ];

  meta = with lib; {
    homepage = "https://pa-dlna.readthedocs.io/en/stable/";
    description = "An UPnP control point forwarding PulseAudio streams to DLNA devices";
    mainProgram = "pa-dlna";
    license = licenses.mit;
    maintainers = with maintainers; [ colinsane ];
  };
}
