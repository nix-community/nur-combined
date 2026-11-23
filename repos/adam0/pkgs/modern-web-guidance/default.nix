{
  # keep-sorted start
  fetchurl,
  lib,
  makeWrapper,
  nodejs,
  stdenvNoCC,
  # keep-sorted end
  # Replacement guides/ directory, laid out as guides/<category>/<id>.md.
  guides ? null,
}: let
  inherit
    (lib)
    # keep-sorted start
    getExe
    optionalString
    # keep-sorted end
    ;
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "modern-web-guidance";
    version = "1.0.2";

    src = fetchurl {
      url = "https://registry.npmjs.org/modern-web-guidance/-/modern-web-guidance-${finalAttrs.version}.tgz";
      hash = "sha256-jDRt8XjJYoSmUWkg4YL3B4nUZB8PuKyyITZCWVNsUA0=";
    };

    # Nix owns installation, so the npx install, update and uninstall commands, the update notice and telemetry are removed.
    patches = [./nix-managed.patch];

    # The minified scanner is patched by substitution; a diff of its single long line would be unreadable.
    postPatch = ''
      substituteInPlace skills/modern-web-guidance/legacy-scan.mjs \
        --replace-fail 'npx modern-web-guidance retrieve' 'modern-web-guidance retrieve'
    '';

    nativeBuildInputs = [
      # keep-sorted start
      makeWrapper
      nodejs
      # keep-sorted end
    ];

    dontBuild = true;

    installPhase =
      ''
        runHook preInstall

        lib=$out/lib/node_modules/modern-web-guidance
        skill=$lib/skills/modern-web-guidance
        mkdir -p $skill
        cp package.json LICENSE THIRD_PARTY_NOTICES $lib/
        cp -r skills/modern-web-guidance/{gen,guides,legacy-scan.mjs,modern-web.mjs,package.json,search.mjs,skill-version.txt} $skill/
      ''
      + optionalString (guides != null) ''
        rm -r $skill/guides
        cp -r ${guides} $skill/guides
        chmod -R u+w $skill/guides
      ''
      + ''
        # Built-in AI and WebMCP guides are cut; search must not return guides without a file.
        rm -rf $skill/guides/{built-in-ai,webmcp}
        node ${./prune-index.mjs} $skill

        makeWrapper ${getExe nodejs} $out/bin/modern-web-guidance \
          --add-flags $skill/modern-web.mjs \
          --set DISABLE_TELEMETRY 1

        runHook postInstall
      '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      export HOME="$TMPDIR"

      $out/bin/modern-web-guidance list > list.json
      $out/bin/modern-web-guidance search "prompt api built-in ai" > search.json
      $out/bin/modern-web-guidance search "webmcp agent tools" >> search.json
      if grep -E '"id":"(agentic-|language-|summarizer|translator|webmcp)' list.json search.json; then
        echo "pruned guides are still listed" >&2
        exit 1
      fi
      $out/bin/modern-web-guidance retrieve accessibility > /dev/null

      runHook postInstallCheck
    '';

    meta = with lib; {
      # keep-sorted start
      description = "Google Chrome's modern web guidance CLI for coding agents, without telemetry or self-installation";
      homepage = "https://developer.chrome.com/docs/modern-web-guidance";
      license = licenses.asl20;
      mainProgram = "modern-web-guidance";
      platforms = platforms.all;
      # keep-sorted end
    };
  })
