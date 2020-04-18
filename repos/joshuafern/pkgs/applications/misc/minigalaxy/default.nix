{ buildPythonApplication, lib, fetchFromGitHub, glib-networking
, gobjectIntrospection, gtk3, setuptools, gettext, wrapGAppsHook, docutils
, pygobject3, requests, steam-run, webkitgtk }:

buildPythonApplication rec {
  pname = "minigalaxy";
  version = "2020-04-18";

  src = fetchFromGitHub {
    owner = "sharkwouter";
    repo = pname;
    rev = "5a19885d326b92e537a2da0d18f96ac8e11fde40";
    sha256 = "1p7j2ip7gz4cnqy5pzs56c542qihskqbszi9hwdsiq8kkzhh02vr";
  };

  doCheck = false;
  enableParallelBuilding = true;
  # Disable Webkit Compositing to fix a bug with Nvidia GPUs on the login screen
  makeWrapperArgs = [ "--prefix WEBKIT_DISABLE_COMPOSITING_MODE : 1" ];

  buildInputs = [ glib-networking gobjectIntrospection gtk3 setuptools ];
  nativeBuildInputs = [ gettext wrapGAppsHook ];
  propagatedBuildInputs = [ docutils pygobject3 requests steam-run webkitgtk ];

  # Prevent homeless error
  preCheck = "export HOME=$PWD";

  # Run games using the Steam Runtime by using steam-run in the wrapper
  postFixup = ''
    sed -e 's/exec -a "$0"/exec -a "$0" steam-run/' -i $out/bin/minigalaxy
  '';

  meta = with lib; {
    homepage = "https://sharkwouter.github.io/minigalaxy/";
    downloadPage = "https://github.com/sharkwouter/minigalaxy/releases";
    description = "A simple GOG client for Linux";
    license = licenses.gpl3;
    maintainers = with maintainers; [ joshuafern ];
    platforms = platforms.linux;
  };
}
