{ lib
, buildPythonApplication
, fetchFromGitHub
, wrapGAppsHook
, setuptools
, pillow
, pygobject3
, pyzmq
, qrcode
, setproctitle
, gobject-introspection
, libnotify
, nix-update-script
}:
buildPythonApplication rec {
  pname = "a2ln";
  version = "1.1.14";

  src = fetchFromGitHub {
    repo = "a2ln-server";
    owner = "patri9ck";
    rev = version;
    hash = "sha256-6SVAFeVB/YpddJhSHgjIF43i2BAmFFADMwlygp9IrSU=";
  };

  format = "pyproject";

  buildInputs = [ wrapGAppsHook setuptools ];

  propagatedBuildInputs = [
    pillow
    pygobject3
    pyzmq
    qrcode
    setproctitle

    gobject-introspection
    libnotify
  ];

  strictDeps = false;

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A way to display Android phone notifications on Linux";
    homepage = "https://github.com/patri9ck/a2ln-server";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
