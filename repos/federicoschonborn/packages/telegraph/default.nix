{ lib
, python3Packages
, fetchFromGitHub
, desktop-file-utils
, gtk4
, libadwaita
, meson
, ninja
, pkg-config
, wrapGAppsHook4
, nix-update-script
}:

python3Packages.buildPythonApplication rec {
  pname = "telegraph";
  version = "0.1.7";

  format = "other";

  src = fetchFromGitHub {
    owner = "fkinoshita";
    repo = "Telegraph";
    rev = version;
    hash = "sha256-eYivvuycMhBC9MMJHugTsZUu5M7V8AbkQUWsfybHETU=";
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
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
  ];

  dontWrapGApps = true;
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Write and decode morse";
    homepage = "https://github.com/fkinoshita/Telegraph";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
