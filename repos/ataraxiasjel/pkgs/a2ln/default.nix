{ lib
, python3Packages
, fetchFromGitHub
, gobject-introspection
, libnotify
, wrapGAppsHook
, nix-update-script
}:
python3Packages.buildPythonApplication rec {
  pname = "a2ln";
  version = "1.1.12";

  src = fetchFromGitHub {
    repo = "a2ln-server";
    owner = "patri9ck";
    rev = version;
    hash = "sha256-w7BaVZ4bPniN7L4fb2KhSVf/0/MMrUOQqldh/IWwWMg=";
  };

  format = "pyproject";

  buildInputs = [ wrapGAppsHook python3Packages.setuptools ];

  propagatedBuildInputs = with python3Packages; [
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
