{ lib, python, fetchFromGitHub, boost, alsa-lib, jack2, pkg-config, meson, ninja, tkinter, scdoc }:

python.pkgs.buildPythonPackage rec {
  pname = "mididings";
  version = "unstable-20250818";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mididings";
    repo = "mididings";
    rev = "7949b8ee038f3be1b8da17e122fbe646cb4bc02e";
    hash = "sha256-+CGLUPZg/NtZOe3vAv9pEzReUmVRJe+CmfRyvIlGjF4=";
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
    inotify-simple # Alternative to pyinotify
  ]);

  # Note: pysmf is not available in nixpkgs, so MIDI file functionality won't work
  # inotify-simple is used instead of pyinotify (same functionality)


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
