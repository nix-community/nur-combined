{ buildPythonApplication, lib, fetchFromGitHub, glib-networking
, gobjectIntrospection, gtk3, setuptools, gettext, wrapGAppsHook, docutils
, pygobject3, requests, steam-run, webkitgtk }:

buildPythonApplication rec {
  pname = "minigalaxy";
  version = "2020-04-11";

  src = fetchFromGitHub {
    owner = "sharkwouter";
    repo = pname;
    rev = "d0e596d5d07d0f5b1d2f8c87788a887dfcf799a1";
    sha256 = "0pk9a3zrlbi1rvqwiyl4mq5lx7wlrlxhsnh0hknjihv4qbv3nqky";
  };

  doCheck = false;
  enableParallelBuilding = true;
  # Disable Webkit Compositing to fix a bug with Nvidia GPUs on the login screen
  makeWrapperArgs = [ "--prefix WEBKIT_DISABLE_COMPOSITING_MODE : 1" ];

  buildInputs = [ glib-networking gobjectIntrospection gtk3 setuptools ];
  nativeBuildInputs = [ gettext wrapGAppsHook ];
  propagatedBuildInputs = [ docutils pygobject3 requests steam-run webkitgtk ];

  # This patch fixes a missing file error, see: sharkwouter/minigalaxy/pull/131
  patchPhase = ''
    substituteInPlace setup.py --replace \
    "subprocess.run(['scripts/compile-translations.sh'])" \
    "subprocess.run(['bash', 'scripts/compile-translations.sh'])"
  '';

  # Prevent homeless error
  preCheck = "export HOME=$PWD";

  # Run games using the Steam Runtime by using steam-run in the wrapper
  postFixup = ''
    sed -e 's/exec -a "$0"/exec -a "$0" steam-run/' -i $out/bin/minigalaxy
  '';

  meta = with lib; {
    homepage = "https://sharkwouter.github.io/minigalaxy/";
    description = "A simple GOG client for Linux";
    license = licenses.gpl3;
    maintainers = with maintainers; [ joshuafern ];
    platforms = platforms.linux;
  };
}
