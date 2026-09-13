{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
  perl,
}:

let
  pname = "anything-llm";
  version = "1.16.1";

  source =
    if stdenv.hostPlatform.isAarch64 then
      {
        asset = "AnythingLLMDesktop-Arm64.AppImage";
        hash = "sha256-QcC5gRfKgQXgoWFZnn+wYS3iZORM23jcL1wx1dHT3PE=";
      }
    else
      {
        asset = "AnythingLLMDesktop.AppImage";
        hash = "sha256-Yo3X/CMg0lj/kT+rZrY5vCtP51mP7etkeW12UJY1cEY=";
      };

  src = fetchurl {
    url = "https://github.com/Mintplex-Labs/anything-llm/releases/download/v${version}/${source.asset}";
    inherit (source) hash;
  };

  prismaTarget =
    if stdenv.hostPlatform.isAarch64 then
      "linux-arm64-openssl-3.0.x"
    else
      "debian-openssl-3.0.x";

  appimageContents = appimageTools.extract {
    inherit pname version src;

    # Upstream identifies NixOS as the unsupported `linux-nixos` Prisma
    # target and tries to download engines that do not exist. Replace that
    # bootstrap helper with one that uses the engines bundled in the AppImage
    # and makes the generated client writable before refreshing it. Also drop
    # the redundant second client generation, which otherwise tries to
    # overwrite the read-only files copied from the Nix store. Replacements
    # are padded to their original byte lengths so the asar offsets stay valid.
    postExtract = ''
      chmod u+w "$out/resources/app.asar"
      ${perl}/bin/perl -0777 -pi -e '
        s#async function gZ\(\).*?(?=function mZ)#do {
          my $replacement = q!async function gZ(){const t=process.env.PRISMA_CLIENT_OUTPUT_DIR;be.existsSync(t)&&ve.spawnSync("chmod",["-R","u+w",t]);const e=Ee.join(he.app.getAppPath(),"../backend");return{queryEnginePath:Ee.join(e,"node_modules/.prisma/client/libquery_engine-${prismaTarget}.so.node"),schemaEnginePath:Ee.join(e,"node_modules/@prisma/engines/schema-engine-${prismaTarget}")}}!;
          die "Prisma helper replacement is too long" if length($replacement) > length($&);
          $replacement . (" " x (length($&) - length($replacement)))
        }#se or die "Prisma helper not found\n";
        s#,"mac"!==s&&\(n=await bZ\(Ee\.join\(i,"node_modules","prisma"\),\["generate"\].*?(?=\}function EZ)#" " x length($&)#se
          or die "duplicate Prisma generate call not found\n";
      ' "$out/resources/app.asar"
    '';
  };
in
appimageTools.wrapAppImage {
  inherit pname version;
  src = appimageContents;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/*.desktop \
      "$out/share/applications/anything-llm.desktop"
    substituteInPlace "$out/share/applications/anything-llm.desktop" \
      --replace-fail "Exec=AppRun" "Exec=anything-llm"

    if [ -d ${appimageContents}/usr/share/icons ]; then
      mkdir -p "$out/share"
      cp -r ${appimageContents}/usr/share/icons "$out/share/"
    fi
  '';

  passthru = { inherit src; };

  meta = {
    description = "All-in-one AI application for chatting with documents and using AI agents";
    homepage = "https://anythingllm.com";
    changelog = "https://github.com/Mintplex-Labs/anything-llm/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "anything-llm";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [
      {
        name = "Souheab";
        github = "Souheab";
        githubId = 85948717;
      }
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
