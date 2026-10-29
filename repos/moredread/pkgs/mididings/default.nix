{ lib, python, fetchFromGitHub, boost, alsa-lib, jack2, pkg-config, meson, ninja, tkinter, scdoc }:

python.pkgs.buildPythonPackage rec {
  pname = "mididings";
  version = "20260601";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mididings";
    repo = "mididings";
    tag = version;
    hash = "sha256-4aVVayhFqlZCQ3UE0hBmy221w0eAyh8stDszLdyqSFs=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
  ] ++ (with python.pkgs; [
    meson-python
    setuptools
  ]);

  buildInputs = [
    boost
    alsa-lib
    jack2
  ];

  propagatedBuildInputs = [
    boost
    alsa-lib
    jack2
    tkinter
  ] ++ (with python.pkgs; [
    decorator
    pyliblo3
    dbus-python
    pyxdg
    watchdog # used by mididings.extra.inotify (AutoRestart)
  ]);

  # Note: pysmf is not available in nixpkgs, so MIDI file functionality won't work


  # Skip tests as they may require MIDI hardware
  doCheck = false;


  # Build man pages manually (meson-python can't include them in wheels)
  postFixup = ''
    mkdir -p $out/share/man/man1
    for page in mididings livedings send_midi; do
      ${scdoc}/bin/scdoc < $src/doc/man/$page.scd > $out/share/man/man1/$page.1
    done
  '';

  # Skip runtime deps check as it's overly strict about boost
  dontCheckRuntimeDeps = true;

  meta = with lib; {
    description = "A MIDI router and processor based on Python, supporting ALSA and JACK MIDI";
    homepage = "https://github.com/mididings/mididings";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
