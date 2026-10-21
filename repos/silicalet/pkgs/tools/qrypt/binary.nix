{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  installShellFiles,
  fuse3,
  cacert,
  tzdata,
}:

let
  sources = {
    x86_64-linux = import ./sources/x86_64-linux.nix;
    aarch64-linux = import ./sources/aarch64-linux.nix;
  };
  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "qrypt-bin is unsupported on ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "qrypt-bin";
  inherit (source) version;

  src = fetchurl {
    inherit (source) url hash;
  };

  sourceRoot = ".";
  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];
  dontBuild = true;
  # The official release statically links Go, glibc and libfuse3.
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 ${source.binary} "$out/bin/qrypt"
    wrapProgram "$out/bin/qrypt" \
      --prefix PATH : /run/wrappers/bin \
      --suffix PATH : ${lib.makeBinPath [ fuse3 ]} \
      --set-default SSL_CERT_FILE ${cacert}/etc/ssl/certs/ca-bundle.crt \
      --set-default ZONEINFO ${tzdata}/share/zoneinfo
    ${lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      installShellCompletion --cmd qrypt \
        --bash <("$out/bin/qrypt" completion bash) \
        --fish <("$out/bin/qrypt" completion fish) \
        --zsh <("$out/bin/qrypt" completion zsh)
    ''}
    runHook postInstall
  '';

  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  installCheckPhase = ''
    runHook preInstallCheck
    export HOME="$TMPDIR/qrypt-home"
    mkdir -p "$HOME" "$TMPDIR/backend"
    "$out/bin/qrypt" --version | grep -F 'v${source.version}'
    "$out/bin/qrypt" --help > /dev/null
    cat > "$TMPDIR/qrypt.toml" <<EOF
    [[mounts]]
    name = "local"
    type = "localfs"
    [mounts.params]
    root_path = "$TMPDIR/backend"
    [mounts.encryption]
    password = "nix-install-check"
    filename_encryption = "standard"
    filename_encoding = "base32"
    [mounts.upload]
    upload_delay = "1ms"
    EOF
    printf 'qrypt encrypted round trip\n' > "$TMPDIR/plaintext"
    "$out/bin/qrypt" fs put --config "$TMPDIR/qrypt.toml" \
      "$TMPDIR/plaintext" /local/check.txt
    # Read with a fresh cache to verify the encrypted backend, not staged data.
    mkdir -p "$TMPDIR/qrypt-reader"
    HOME="$TMPDIR/qrypt-reader" "$out/bin/qrypt" fs cat --config "$TMPDIR/qrypt.toml" \
      /local/check.txt > "$TMPDIR/decrypted"
    cmp "$TMPDIR/plaintext" "$TMPDIR/decrypted"
    test ! -e "$TMPDIR/backend/check.txt"
    if grep -r -F 'qrypt encrypted round trip' "$TMPDIR/backend"; then
      echo "Plaintext found in encrypted backend" >&2
      exit 1
    fi
    runHook postInstallCheck
  '';

  meta = {
    description = "Cloud drive CLI and FUSE filesystem with rclone-compatible encryption";
    homepage = "https://github.com/yinzhenyu-su/qrypt";
    changelog = "https://github.com/yinzhenyu-su/qrypt/releases/tag/v${source.version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "qrypt";
    platforms = builtins.attrNames sources;
  };
}
