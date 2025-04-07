{
  lib,
  stdenv,
  pkgs,
  fetchFromGitHub,
  ...
}:

stdenv.mkDerivation {
  pname = "libgray";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "Fabric-Development";  # Change this
    repo = "gray";
    rev = "d5a8452c39b074ef6da25be95305a22203cf230e";  # Or your specific commit hash
    hash = "sha256-s9v9fkp+XrKqY81Z7ezxMikwcL4HHS3KvEwrrudJutw=";  # You'll need to add the correct hash
  };

  nativeBuildInputs = with pkgs; [
    gobject-introspection
    meson
    pkg-config
    ninja
    vala
  ];

  buildInputs = with pkgs; [
    glib
    libdbusmenu-gtk3
    gtk3
  ];

  outputs = ["out" "dev"];

  meta = with lib; {
    description = "system trays for everyone ⚡";
    homepage = "https://github.com/your-github-username/gray";  # Change this
    license = licenses.agpl3Only;  # Or whatever license you're using
    maintainers = [
      {
        email = "heyimkyu@mailbox.org";
        github = "HeyImKyu";
        githubId = 43815343;
        name = "Kyu";
      }
    ];
  };
}
