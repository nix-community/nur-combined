{
  linguee-api,
  python3,
  writeShellApplication
}:

writeShellApplication {
    name = "linguee-api-server";
    runtimeInputs = [ (python3.withPackages (p: [ p.uvicorn linguee-api ])) ];
    text = ''
      uvicorn "$@" linguee_api.api:app
    '';
}
