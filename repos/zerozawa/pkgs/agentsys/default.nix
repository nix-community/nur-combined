{
  lib,
  rustPlatform,
  fetchFromGitHub,
  buildEnv,
  buildNpmPackage,
  nodejs,
  makeWrapper,
  stdenv,
  yq-go,
  /**
    * for customizing skill/command/agent definitions without modifying original markdown files, e.g. to override the model field for a specific skill.
    * key: file path eg. `agents/xxx.md` or `commands/xxx.md`
    * value: attrset for overriding fields in skill/command/agent front-matter; null removes a field
   */
  frontmattersOverride ? {},
  ...
}: let
  frontmattersJson = builtins.toJSON frontmattersOverride;

  # 优先使用git tag，若无则使用commit hash
  resourceHandler = {
    agentsys = {
      r = "5.4.1";
      h = "sha256-aHSUbMsnYwO/0F0qXUoI0Vp3sazhdw1AqpXv+88qkf8=";
      npmDepsHash = "sha256-V7wzm9T0GhC+iThS/c1dpEi7tJZaxnb3VO874lAWlsw=";
    };
    agnix = {
      r = "0.16.2";
      h = "sha256-5Hpz7LZPrlARbc0KsDh/G2cEADYIo/DNS3gq0ZcREVs=";
      cargoHash = "sha256-pn5X4MDGfH/fN1mcB3ar/jJ83qqdZuuDGRZT5EQf1dw=";
    };
    audit-project = {
      r = "d8de1816c997e8811ce8a75cf3efda6cc432362b";
      h = "sha256-cJhaQN0xqkfIM4sGWW+y8XxbOMxUWnMkE9Xv+Dy1XFs=";
    };
    consult = {
      r = "0b61b53cc62e9edd26f2835e6c9f39ee9f22fd5f";
      h = "sha256-Qqv0k9PTn1ep51JCO/y/p+FyUZxXE7wZ7hapiupmGIU=";
    };
    debate = {
      r = "7d86f892cf179ad33ca6dc8ad15cbb42a02093b8";
      h = "sha256-bPaBa6ei18ryIUhGjGPAtkUg5jkDc2tlQ/Ac5D+tj7c=";
    };
    deslop = {
      r = "ba8e7364528ccd208eced2c082910a07d8eb0db4";
      h = "sha256-Za3qwy4uvhlsKUNoUwkAKHQI6aJ0EnnW1QRHL+TkRFY=";
    };
    drift-detect = {
      r = "2fa2a8cd8fcd8619c774507f5e3d1217fc390b24";
      h = "sha256-SBtwwkOA6gwCC4Sz5yUG0r6Y2W7MNzAtc9/dRI85Rdg=";
    };
    enhance = {
      r = "62548cc9e89c8cc2369e6ad6ae21bccc10645d3b";
      h = "sha256-IF31ic0vdz4xm7ZNMgAzFIIwPRFLAmbl419g5Hlkhq0=";
    };
    learn = {
      r = "5b24c75bfaa7e62914f1024bea15c5a2e5cdad58";
      h = "sha256-S/UL0l+WTSRqgB5mibQrK1xd0R1lW4wAffEQx/a4BWM=";
    };
    next-task = {
      r = "1.1.0";
      h = "sha256-NxBuMul1YAUtLbWunA6Q4UiNdXzhvZzSCt/u3dT5Ud8=";
    };
    perf = {
      r = "5cd135f5b32afac20695e4207502b66cd515bb4c";
      h = "sha256-HGWC6CdK9atRwSJCbIW2adtt2WtkEcNPq9iCBdoiuoE=";
    };
    repo-map = {
      r = "ff4dfeb6776b9f3885ca6d3dcc0ecc360a7d4a0f";
      h = "sha256-lzofuG+xHQZ5iPo9vo+EaF2XgkXCDmONYcOFGp0fMgk=";
    };
    ship = {
      r = "1.1.1";
      h = "sha256-ZfZWnKUhqa8BqOzOS8GI6iZzQyiGUUe+hC0ES4iH3V0=";
    };
    skillers = {
      r = "0.2.0";
      h = "sha256-AGndaNZRIMNOaSSkFAEqTGGeQ2RXNZmnow38OP+8XRo=";
    };
    sync-docs = {
      r = "d2544b2015ad2cc2abab787c83671e3b52115983";
      h = "sha256-bjnsvwwgTFv0A5HqbTcc+y990TV7XyBHwintSYd/md0=";
    };
    web-ctl = {
      r = "f32bc2f1d05ec663eea493bee78a0f313ba77046";
      h = "sha256-6xj1Tpag9h3B4PHcL1JEQyPrClFIwbBm1Q4KOhRrxWw=";
    };
  };
  fetchPlugin = repo: rev: sha256:
    fetchFromGitHub {
      owner = "agent-sh";
      inherit repo rev sha256;
    };

  agentsysMain = fetchPlugin "agentsys" "v${resourceHandler.agentsys.r}" "${resourceHandler.agentsys.h}";

  agnixSrc = fetchPlugin "agnix" "v${resourceHandler.agnix.r}" "${resourceHandler.agnix.h}";

  plugins = {
    audit-project = fetchPlugin "audit-project" resourceHandler.audit-project.r resourceHandler.audit-project.h;
    consult = fetchPlugin "consult" resourceHandler.consult.r resourceHandler.consult.h;
    debate = fetchPlugin "debate" resourceHandler.debate.r resourceHandler.debate.h;
    deslop = fetchPlugin "deslop" resourceHandler.deslop.r resourceHandler.deslop.h;
    drift-detect = fetchPlugin "drift-detect" resourceHandler.drift-detect.r resourceHandler.drift-detect.h;
    enhance = fetchPlugin "enhance" resourceHandler.enhance.r resourceHandler.enhance.h;
    learn = fetchPlugin "learn" resourceHandler.learn.r resourceHandler.learn.h;
    next-task = fetchPlugin "next-task" "v${resourceHandler.next-task.r}" resourceHandler.next-task.h;
    perf = fetchPlugin "perf" resourceHandler.perf.r resourceHandler.perf.h;
    repo-map = fetchPlugin "repo-map" resourceHandler.repo-map.r resourceHandler.repo-map.h;
    ship = fetchPlugin "ship" "v${resourceHandler.ship.r}" resourceHandler.ship.h;
    skillers = fetchPlugin "skillers" "v${resourceHandler.skillers.r}" resourceHandler.skillers.h;
    sync-docs = fetchPlugin "sync-docs" resourceHandler.sync-docs.r resourceHandler.sync-docs.h;
    web-ctl = fetchPlugin "web-ctl" resourceHandler.web-ctl.r resourceHandler.web-ctl.h;
  };

  mkdirGeneralPlugin = pname: version: src: (stdenv.mkDerivation {
    inherit pname version src;
    nativeBuildInputs = [yq-go];
    dontBuild = true;
    installPhase = ''
      frontmatters_json_file="$TMPDIR/agentsys-model-overrides.json"
      cat > "$frontmatters_json_file" <<'EOF'
${frontmattersJson}
EOF

      apply_frontmatter_overrides() {
        local file="$1"
        local relative_path="$2"
        local override_json
        local key
        local value_json

        override_json="$(FRONTMATTER_PATH="$relative_path" yq -o=json -I=0 '.[strenv(FRONTMATTER_PATH)]' "$frontmatters_json_file")"

        if [ "$override_json" = "null" ] || [ "$override_json" = "{}" ]; then
          return 0
        fi

        while IFS= read -r key; do
          value_json="$(printf '%s' "$override_json" | FIELD_NAME="$key" yq -o=json -I=0 '.[strenv(FIELD_NAME)]')"

          if [ "$value_json" = "null" ]; then
            FIELD_NAME="$key" yq --front-matter=process -P -i 'del(.[strenv(FIELD_NAME)])' "$file"
          else
            FIELD_NAME="$key" FIELD_VALUE_JSON="$value_json" yq --front-matter=process -P -i '.[strenv(FIELD_NAME)] = (strenv(FIELD_VALUE_JSON) | fromjson)' "$file"
          fi
        done < <(printf '%s' "$override_json" | yq -r 'keys | .[]')
      }

      normalize_skill() {
        local file="$1"
        local relative_path="$2"

        yq --front-matter=process -P -i '
          del(.allowed-tools, .tools, .model, .agent, .mode, .codex-description)
        ' "$file"

        apply_frontmatter_overrides "$file" "$relative_path"
      }

      normalize_command() {
        local file="$1"
        local relative_path="$2"

        yq --front-matter=process -P -i '
          .agent = "general"
          | del(.allowed-tools, .tools, .model, .mode, .codex-description)
        ' "$file"

        apply_frontmatter_overrides "$file" "$relative_path"
      }

      normalize_agent() {
        local file="$1"
        local relative_path="$2"

        yq --front-matter=process -P -i '
          .mode = "subagent"
          | del(.allowed-tools, .tools, .model, .agent, .codex-description)
        ' "$file"

        apply_frontmatter_overrides "$file" "$relative_path"
      }

      mkdir -p $out/share/opencode/skills
      mkdir -p $out/share/opencode/commands
      mkdir -p $out/share/opencode/agents

      if [ -d "$src/skills" ]; then
        cp -r $src/skills/* $out/share/opencode/skills/
        chmod -R u+w $out/share/opencode/skills
        find $out/share/opencode/skills -type f -name 'SKILL.md' | while read -r file; do
          normalize_skill "$file" "skills/''${file#$out/share/opencode/skills/}"
        done
      fi

      if [ -d "$src/commands" ]; then
        cp -r $src/commands/* $out/share/opencode/commands/
        chmod -R u+w $out/share/opencode/commands
        find $out/share/opencode/commands -type f -name '*.md' | while read -r file; do
          normalize_command "$file" "commands/''${file#$out/share/opencode/commands/}"
        done
      fi

      if [ -d "$src/agents" ]; then
        cp -r $src/agents/* $out/share/opencode/agents/
        chmod -R u+w $out/share/opencode/agents
        find $out/share/opencode/agents -type f -name '*.md' | while read -r file; do
          normalize_agent "$file" "agents/''${file#$out/share/opencode/agents/}"
        done
      fi
    '';
  });

  components = [
    (rustPlatform.buildRustPackage
      {
        pname = "agnix";
        version = resourceHandler.agnix.r;
        src = agnixSrc;
        inherit (resourceHandler.agnix) cargoHash;
        cargoBuildFlags = ["-p" "agnix-cli"];
        doCheck = false;
      })
    (buildNpmPackage {
      pname = "agentsys";
      version = resourceHandler.agentsys.r;
      src = agentsysMain;
      inherit (resourceHandler.agentsys) npmDepsHash;

      patches = [./agentsys-nix-runtime.patch];

      nativeBuildInputs = [makeWrapper];

      buildInputs = [nodejs];

      # 跳过测试阶段（在 Nix 构建中通常跳过）
      doCheck = false;
      checkPhase = ''
        runHook preCheck
        # CI 中的测试步骤
        npm run validate
        runHook postCheck
      '';

      dontBuild = true; # 因为直接复制文件，不需要 npm build

      installPhase = ''
        runHook preInstall

        # 安装所有文件到 $out
        mkdir -p $out/lib/node_modules/agentsys
        cp -r . $out/lib/node_modules/agentsys/

        # 创建可执行文件链接
        mkdir -p $out/bin
        ln -s $out/lib/node_modules/agentsys/bin/cli.js $out/bin/agentsys
        ln -s $out/lib/node_modules/agentsys/bin/dev-cli.js $out/bin/agentsys-dev

        wrapProgram $out/bin/agentsys --prefix PATH : "${nodejs}/bin"
        wrapProgram $out/bin/agentsys-dev --prefix PATH : "${nodejs}/bin"

        # 安装 OpenCode 插件适配器
        mkdir -p $out/share/opencode/plugins
        cp $src/adapters/opencode-plugin/index.ts $out/share/opencode/plugins/
        mkdir -p $out/share/opencode/commands
        cp -r $src/lib $out/share/opencode/commands/

        runHook postInstall
      '';
    })
    (mkdirGeneralPlugin "agnix" resourceHandler.agnix.r agnixSrc)
    (mkdirGeneralPlugin "audit-project" "0-unstable-${builtins.substring 0 7 resourceHandler.audit-project.r}" plugins."audit-project")
    (mkdirGeneralPlugin "consult" "0-unstable-${builtins.substring 0 7 resourceHandler.consult.r}" plugins.consult)
    (mkdirGeneralPlugin "debate" "0-unstable-${builtins.substring 0 7 resourceHandler.debate.r}" plugins.debate)
    (mkdirGeneralPlugin "deslop" "0-unstable-${builtins.substring 0 7 resourceHandler.deslop.r}" plugins.deslop)
    (mkdirGeneralPlugin "drift-detect" "0-unstable-${builtins.substring 0 7 resourceHandler.drift-detect.r}" plugins."drift-detect")
    (mkdirGeneralPlugin "enhance" "0-unstable-${builtins.substring 0 7 resourceHandler.enhance.r}" plugins.enhance)
    (mkdirGeneralPlugin "learn" "0-unstable-${builtins.substring 0 7 resourceHandler.learn.r}" plugins.learn)
    (mkdirGeneralPlugin "next-task" resourceHandler.next-task.r plugins."next-task")
    (mkdirGeneralPlugin "perf" "0-unstable-${builtins.substring 0 7 resourceHandler.perf.r}" plugins.perf)
    (mkdirGeneralPlugin "repo-map" "0-unstable-${builtins.substring 0 7 resourceHandler.repo-map.r}" plugins."repo-map")
    (mkdirGeneralPlugin "ship" resourceHandler.ship.r plugins.ship)
    (mkdirGeneralPlugin "skillers" resourceHandler.skillers.r plugins.skillers)
    (mkdirGeneralPlugin "sync-docs" "0-unstable-${builtins.substring 0 7 resourceHandler.sync-docs.r}" plugins."sync-docs")
    (mkdirGeneralPlugin "web-ctl" "0-unstable-${builtins.substring 0 7 resourceHandler.web-ctl.r}" plugins."web-ctl")
  ];
in
  buildEnv rec {
    pname = "agentsys";
    version = resourceHandler.agentsys.r;
    name = "${pname}-${version}";
    paths = components;

    meta = with lib; {
      description = "AI writes code. This automates everything else · 15 plugins, 35 agents, and 32 skills · for Claude Code, OpenCode, Codex, cursor, kiro.";
      homepage = "https://github.com/agent-sh/agentsys";
      license = with licenses; [mit];
      mainProgram = pname;
      platforms = platforms.all;
      sourceProvenance = with sourceTypes; [fromSource];
    };
  }
