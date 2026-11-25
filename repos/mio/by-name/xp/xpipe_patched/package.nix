{
  lib,
  stdenvNoCC,
  xpipe,
  fetchurl,
  undmg,
  makeWrapper,
  writeShellApplication,
  python3,
  nix,
  git,
  cacert,
}:

let
  version = "24.10";
  system = stdenvNoCC.hostPlatform.system;
  arch =
    {
      aarch64-darwin = "arm64";
      x86_64-darwin = "x86_64";
    }
    .${system} or (throw "Unsupported system: ${system}");
  hash =
    {
      aarch64-darwin = "sha256-l1Dkx7k6NYpUOxLcudYP0O0/IOIGQLHDIFa6vKnarTU=";
      x86_64-darwin = "sha256-ITVW3+MkjOFvZvVyYoEAMvKUectAhbtLdpNaz2xDM80=";
    }
    .${system} or (throw "Unsupported system: ${system}");
in

# nixpkgs' xpipe only packages the Linux portable bundle. The macOS release is
# a self-contained jpackage app, so it needs a separate source and install path.
xpipe.overrideAttrs (
  old:
  lib.optionalAttrs stdenvNoCC.hostPlatform.isDarwin {
    pname = "xpipe_patched";
    inherit version;

    src = fetchurl {
      url = "https://github.com/xpipe-io/xpipe/releases/download/${version}/xpipe-portable-macos-${arch}.dmg";
      inherit hash;
    };

    nativeBuildInputs = [
      undmg
      makeWrapper
    ];
    buildInputs = [ ];

    # Keep the signed app bundle byte-for-byte intact. Darwin fixup otherwise
    # rewrites the shebangs of scripts inside the bundle and invalidates its
    # code signature.
    dontFixup = true;

    desktopItem = null;
    sourceRoot = ".";

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      test -x "$out/Applications/XPipe.app/Contents/MacOS/xpipe"
      test -x "$out/Applications/XPipe.app/Contents/MacOS/xpiped"
      test -x "$out/bin/xpipe"
      test -x "$out/bin/xpiped"
      test -s "$out/Applications/XPipe.app/Contents/Info.plist"
      test -s "$out/Applications/XPipe.app/Contents/_CodeSignature/CodeResources"
      runHook postInstallCheck
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications $out/bin
      cp -R XPipe.app $out/Applications/

      # The jpackage launchers resolve their runtime and app data relative to
      # the executable, so wrappers keep working without flattening the bundle.
      makeWrapper $out/Applications/XPipe.app/Contents/MacOS/xpipe $out/bin/xpipe
      makeWrapper $out/Applications/XPipe.app/Contents/MacOS/xpiped $out/bin/xpiped

      runHook postInstall
    '';

    passthru = (old.passthru or { }) // {
      updateScript = writeShellApplication {
        name = "update-xpipe_patched";
        runtimeInputs = [
          python3
          nix
          git
          cacert
        ];
        text = ''
          export UPDATE_NIX_ATTR_PATH="xpipe_patched"
          export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
          exec ${python3}/bin/python3 ${./update.py} "$@"
        '';
      };
    };

    meta = old.meta // {
      platforms = lib.platforms.darwin;
    };
  }
)
