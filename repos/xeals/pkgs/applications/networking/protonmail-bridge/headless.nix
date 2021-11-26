{}:

{
  pname = "protonmail-bridge-headless";

  tags = [ "pmapi_prod" "nogui" ];

  # REVIEW: Some issue with IMAP tests that probably fail due to network
  # sandboxing.
  doCheck = false;

  # Fix up name.
  postInstall = ''
    mv $out/bin/Desktop-Bridge $out/bin/protonmail-bridge
    mv $out/bin/Import-Export $out/bin/protonmail-import-export
  '';
}
