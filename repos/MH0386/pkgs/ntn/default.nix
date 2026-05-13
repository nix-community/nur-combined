{
  lib,
  fetchurl,
  stdenvNoCC,
  versionCheckHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ntn";
  version = "0.13.2";

  src =
    finalAttrs.passthru.sources.${stdenvNoCC.hostPlatform.system}
      or (throw "ntn is not supported on ${stdenvNoCC.hostPlatform.system}");

  dontConfigure = true;
  dontBuild = true;

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ntn $out/bin/ntn
    install -Dm644 README.md $out/share/doc/${finalAttrs.pname}/README.md
    install -Dm644 LICENSE.md $out/share/licenses/${finalAttrs.pname}/LICENSE.md

    runHook postInstall
  '';

  passthru = {
    sources = {
      x86_64-linux = fetchurl {
        url = "https://ntn.dev/releases/v${finalAttrs.version}/ntn-x86_64-unknown-linux-musl.tar.gz";
        hash = "sha256-RLvPkeETvTPvUnXR7kUWD0RjvdrlO+rrOBJz95fTSck=";
      };
      aarch64-linux = fetchurl {
        url = "https://ntn.dev/releases/v${finalAttrs.version}/ntn-aarch64-unknown-linux-musl.tar.gz";
        hash = "sha256-Ica1fdfn2/i9ZTGRs7jAwBQgQsJJOeurRgSKe58i4uc=";
      };
      x86_64-darwin = fetchurl {
        url = "https://ntn.dev/releases/v${finalAttrs.version}/ntn-x86_64-apple-darwin.tar.gz";
        hash = "sha256-GN1vbCidJPbvYJFgkj1MoC9m6kaRC0X+rkSgKAltclQ=";
      };
      aarch64-darwin = fetchurl {
        url = "https://ntn.dev/releases/v${finalAttrs.version}/ntn-aarch64-apple-darwin.tar.gz";
        hash = "sha256-QM5e10kPk3G8UqKJGHI/XCAQv32benswJz2LY7MNUFQ=";
      };
    };
  };

  meta = {
    description = "CLI for Notion";
    homepage = "https://www.notion.dev";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.MH0386 ];
    mainProgram = "ntn";
    platforms = builtins.attrNames finalAttrs.passthru.sources;
  };
})
