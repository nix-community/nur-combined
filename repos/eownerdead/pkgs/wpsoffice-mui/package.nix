{
  wpsoffice,
  fetchzip,
  p7zip,
}:
let
  mui = fetchzip {
    url = "https://github.com/wachin/wps-office-all-mui-win-language/releases/download/v11.1.0.11704/mui.7z";
    hash = "sha256-T/adeaKbJCONC9dU6SO6TuxLYIqWABJRfoaO/AnSuF8=";
    nativeBuildInputs = [ p7zip ];
  };
in
wpsoffice.overrideAttrs (old: {
  pname = "${old.pname}-mui";

  postInstall = ''
    cp -r ${mui}/* $out/opt/kingsoft/wps-office/office6/mui/
  '';
})
