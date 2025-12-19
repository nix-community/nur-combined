# Credits to: https://fictionbecomesfact.com/notes/cockpit-podman-nixos-setup/
{
  lib,
  stdenv,
  gettext,
  sources,
}:
stdenv.mkDerivation {
  inherit (sources.cockpit-podman) pname version src;

  nativeBuildInputs = [ gettext ];

  makeFlags = [
    "DESTDIR=$(out)"
    "PREFIX="
  ];

  dontBuild = true;

  meta = with lib; {
    description = "Cockpit UI for podman containers";
    license = licenses.lgpl21;
    homepage = "https://github.com/cockpit-project/cockpit-podman";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
