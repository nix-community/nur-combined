{ lib, python3Packages, sftpman, gtk3, sshfs, gobject-introspection, wrapGAppsHook, makeDesktopItem }:

python3Packages.buildPythonApplication rec {
  pname = "sftpman-gtk";
  version = "1.0.3";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "1p4yhsm95xq596yk63x84v440j6lbyr2n0yb6k9c9a32n2cy1qsi";
  };

  nativeBuildInputs = [ wrapGAppsHook ];
  propagatedBuildInputs = with python3Packages; [ sftpman pygobject3 gtk3 gobject-introspection sshfs ];
  doCheck = false;

  desktopItem = makeDesktopItem {
    type = "Application";
    name = "sftpman-gtk";
    comment = "Mount SSHFS/SFTP filesystems";
    icon = "sftpman-gtk.png";
    exec = "sftpman-gtk";
    categories = [ "GTK" "Filesystem" "Network" ];
    terminal = "false";
    desktopName = "sftpman-gtk";
  };

  postInstall = ''
    mkdir -p $out/share/applications $out/share/pixmaps
    cp sftpman-gtk.png $out/share/pixmaps/
    cp ${desktopItem}/share/applications/* $out/share/applications/
  '';

  meta = with lib; {
    homepage = "https://github.com/spantaleev/sftpman-gtk";
    description = "GTK frontend for SftpMan";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ artturin ];
  };
}
