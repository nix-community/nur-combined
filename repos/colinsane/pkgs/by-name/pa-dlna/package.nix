{
  lib,
  fetchFromGitLab,
  libpulseaudio,
  pulseaudio,
  python3,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pa-dlna";
  version = "0.7";
  format = "pyproject";

  src = fetchFromGitLab {
    owner = "xdegaye";
    repo = "pa-dlna";
    rev = "${finalAttrs.version}";
    hash = "sha256-tc3AjxTMeLH82d8R95xsqLeAH1t/orW7c9DGjBwDWaU=";
  };

  postPatch = ''
    substituteInPlace pa_dlna/libpulse/libpulse.py --replace-fail \
      "path = find_library('pulse')" \
      "path = '${lib.getLib libpulseaudio}/lib/libpulse.so'"
  '';

  nativeBuildInputs = [
    python3.pkgs.flit-core
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
    python3.pkgs.wrapPython
  ];

  propagatedBuildInputs = with python3.pkgs; [
    psutil
    # `pa-dlna` shells out to `pa-rec` at runtime.
    pulseaudio
    # optional runtime binaries in case the DLNA renderer does not support PCM L16:
    # ffmpeg flac lame
  ];

  nativeCheckInputs = [
    python3.pkgs.pythonImportsCheckHook
  ];

  postFixup = ''
    wrapPythonPrograms
  '';

  pythonImportsCheck = [
    "pa_dlna"
  ];

  doCheck = true;
  strictDeps = true;

  meta = with lib; {
    homepage = "https://pa-dlna.readthedocs.io/en/stable/";
    description = "An UPnP control point forwarding PulseAudio streams to DLNA devices";
    mainProgram = "pa-dlna";
    license = licenses.mit;
    maintainers = with maintainers; [ colinsane ];
  };
})
