{
  stdenv,
  fetchFromGitHub,
  pkg-config,
  curl,
  gtk3,
}:
stdenv.mkDerivation rec {
  pname = "sgdboop";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "SteamGridDB";
    repo = "SGDBoop";
    rev = "v${version}";
    sha256 = "sha256-FpVQQo2N/qV+cFhYZ1FVm+xlPHSVMH4L+irnQEMlUQs=";
  };

  nativeBuildInputs = [pkg-config];
  buildInputs = [curl gtk3];

  makeFlags = ["PREFIX=$(out)"];

  installPhase = ''
    mkdir -p $out/bin $out/share/applications
    install -Dm755 linux-release/SGDBoop $out/bin/SGDBoop
    cat > $out/share/applications/com.steamgriddb.SGDBoop.desktop << EOF
    [Desktop Entry]
      Name=SGDBoop
      Comment=Apply Steam assets from SteamGridDB
      Exec=$out/bin/SGDBoop %U
      Terminal=false
      Type=Application
      NoDisplay=false
      Icon=com.steamgriddb.SGDBoop
      MimeType=x-scheme-handler/sgdb
      Categories=Utility
    EOF
  '';

  meta.description = "A helper for SteamGridDB.com";
}
