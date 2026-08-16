{
  autoPatchelfHook,
  fetchurl,
  openssl,
  stdenv,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "officecli";
  version = "1.0.144";

  src = fetchurl {
    url = "https://d.officecli.ai/releases/download/v${finalAttrs.version}/officecli-linux-x64";
    hash = "sha256-Mu96IaVKTKbJgGv16fPTK/sSkQFzKcVQRMsqrHGCLrg=";
  };

  dontUnpack = true;
  dontStrip = true;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    openssl
    stdenv.cc.cc.lib
    zlib
  ];

  installPhase = ''
    install -d "$out/bin" "$out/libexec"
    install -m755 "$src" "$out/libexec/officecli"
    cat > "$out/bin/officecli" <<EOF
    #!${stdenv.shell}
    export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
    export OFFICECLI_SKIP_UPDATE=1
    exec "$out/libexec/officecli" "\$@"
    EOF
    chmod +x "$out/bin/officecli"
  '';

  meta = {
    description = "Command-line interface for Office documents";
    homepage = "https://officecli.ai";
    mainProgram = "officecli";
    platforms = [ "x86_64-linux" ];
  };
})
