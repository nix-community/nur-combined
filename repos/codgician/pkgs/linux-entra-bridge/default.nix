{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gitUpdater,
  python3,
  runCommand,
}:

let
  python = python3.withPackages (ps: [ ps.dbus-python ]);
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "linux-entra-bridge";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "Pihaar";
    repo = "linux-entra-bridge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bYLORnMlqI47jUkM7HZJH4L20nnLg/Lgo0Om0vH3r+w=";
  };

  dontBuild = true;

  postPatch = ''
    substituteInPlace native-host/linux_entra_bridge.py \
      --replace-fail '#!/usr/bin/env python3' '#!${python}/bin/python'
  '';

  checkPhase = ''
    runHook preCheck
    ${python}/bin/python -m py_compile native-host/linux_entra_bridge.py
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    host="$out/libexec/${finalAttrs.pname}/linux_entra_bridge.py"
    install -Dm755 native-host/linux_entra_bridge.py "$host"

    for browser in chromium opt/chrome brave-browser vivaldi; do
      manifest="$out/etc/$browser/native-messaging-hosts/linux_entra_bridge.json"
      install -d "$(dirname "$manifest")"
      cat > "$manifest" <<EOF
    {
      "name": "linux_entra_bridge",
      "description": "Microsoft Entra ID SSO via Identity Broker D-Bus",
      "path": "$host",
      "type": "stdio",
      "allowed_origins": ["chrome-extension://dffhogipdmkddjnppibgmgpcobdnaffk/"]
    }
    EOF
    done

    for browser in mozilla librewolf; do
      manifest="$out/lib/$browser/native-messaging-hosts/linux_entra_bridge.json"
      install -d "$(dirname "$manifest")"
      cat > "$manifest" <<EOF
    {
      "name": "linux_entra_bridge",
      "description": "Microsoft Entra ID SSO via Identity Broker D-Bus",
      "path": "$host",
      "type": "stdio",
      "allowed_extensions": ["entra-bridge@linux-entra-bridge", "entra-bridge@linux-entra-bridge.tb"]
    }
    EOF
    done

    extension="$out/share/${finalAttrs.pname}/extension"
    install -d "$extension"
    install -m644 extension/*.js extension/*.html extension/*.css "$extension"
    install -m644 manifests/chromium.json "$extension/manifest.json"
    cp -r extension/icons "$extension"

    runHook postInstall
  '';

  passthru = {
    # Upstream publishes stable versions as v-prefixed Git tags, not GitHub Releases.
    updateScript = gitUpdater { rev-prefix = "v"; };

    nixosModule = import ./module.nix finalAttrs.finalPackage;

    tests.smoke = runCommand "${finalAttrs.pname}-smoke" { } ''
      # A zero-length native message is rejected before any D-Bus connection,
      # exercising the installed host and its Python dbus dependency offline.
      printf '\0\0\0\0' | ${finalAttrs.finalPackage}/libexec/${finalAttrs.pname}/linux_entra_bridge.py > response
      ${python}/bin/python - response <<'PY'
      import json
      import struct
      import sys

      response = open(sys.argv[1], "rb").read()
      length, = struct.unpack("=I", response[:4])
      assert len(response) == 4 + length
      assert json.loads(response[4:]) == {
          "success": False,
          "error": "Malformed message",
      }
      PY
      touch "$out"
    '';
  };

  meta = {
    description = "Cross-browser Microsoft Entra ID SSO on Linux via the Microsoft Identity Broker D-Bus service";
    homepage = "https://github.com/Pihaar/linux-entra-bridge";
    changelog = "https://github.com/Pihaar/linux-entra-bridge/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ codgician ];
  };
})
