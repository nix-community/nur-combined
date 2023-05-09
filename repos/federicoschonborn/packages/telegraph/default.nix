{ lib
, python3
, fetchFromGitHub
, desktop-file-utils
, gtk4
, libadwaita
, meson
, ninja
, pkg-config
, wrapGAppsHook4
}:

python3.pkgs.buildPythonPackage rec {
  pname = "telegraph";
  version = "0.1.5";

  format = "other";

  src = fetchFromGitHub {
    owner = "fkinoshita";
    repo = "Telegraph";
    rev = version;
    hash = "sha256-STV9BIgPm9KWhn81aD5hJDl/gNp1Qri2OMLU01RnNVM=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
    python3
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pygobject3
  ];

  dontWrapGApps = true;
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    description = "Write and decode morse";
    homepage = "https://github.com/fkinoshita/Telegraph";
    license = licenses.gpl3Only;
  };
}
