{
  lib,
  callPackage,
  curl,
  coreutils,

  templateCommands,
  hashUrls,
  versionFile,

  prefetchUnpack ? false,
  extraPreScript ? "",
}:

let
  inherit (lib)
    toUpper
    replaceStrings
    concatStringsSep
    mapAttrsToList
    attrNames
    ;

  debug = false;

  log =
    level: message:
    if level == "DEBUG" && !debug then
      ""
    else
      ''
        printf '[${level}] %s\n' "${message}" >&2
      '';

  sanitize = system: toUpper (replaceStrings [ "-" ] [ "_" ] system);

  safeOutputKey = key: toUpper (replaceStrings [ "-" "." ] [ "_" "_" ] key);

  validOutputKey =
    key: builtins.isString key && builtins.match "[A-Za-z_][A-Za-z0-9_.-]*" key != null;

  placeholderHash = "sha256-0000000000000000000000000000000000000000000=";

  shellParameter = name: "\${" + name + "}";

  normalizeTemplateCommand =
    name: value:
    let
      variableName = toUpper name;
      isVersion = variableName == "VERSION";

      valueIsString = builtins.isString value;
      valueIsAttrs = builtins.isAttrs value;

      command =
        if valueIsString then
          value
        else if valueIsAttrs then
          value.command or null
        else
          null;

      topLevelFields = if valueIsAttrs then attrNames value else [ ];

      unknownTopLevelFields = builtins.filter (
        field:
        !(builtins.elem field [
          "command"
          "json"
        ])
      ) topLevelFields;

      hasJson = valueIsAttrs && builtins.hasAttr "json" value;

      jsonValue = if hasJson then value.json else null;

      jsonIsAttrs = hasJson && builtins.isAttrs jsonValue;

      jsonConfig = if jsonIsAttrs then jsonValue else { };

      jsonFields = attrNames jsonConfig;

      unknownJsonFields = builtins.filter (
        field:
        !(builtins.elem field [
          "key"
          "filter"
        ])
      ) jsonFields;

      jsonKey = if isVersion then jsonConfig.key or "version" else jsonConfig.key or null;

      jsonFilter = jsonConfig.filter or ".";

      shouldPersist = isVersion || hasJson;

      normalizedJson =
        if shouldPersist then
          {
            key = if isVersion then "version" else jsonKey;
            filter = jsonFilter;
          }
        else
          null;
    in
    if !(valueIsString || valueIsAttrs) then
      throw "fetch-urls.nix: ${name} must be a command string or an attribute set"

    else if unknownTopLevelFields != [ ] then
      throw ''
        fetch-urls.nix: unknown fields for ${name}:
        ${concatStringsSep ", " unknownTopLevelFields}
        Allowed fields: command, json
      ''

    else if !builtins.isString command || command == "" then
      throw "fetch-urls.nix: ${name}.command must be a non-empty string"

    else if hasJson && !jsonIsAttrs then
      throw "fetch-urls.nix: ${name}.json must be an attribute set"

    else if unknownJsonFields != [ ] then
      throw ''
        fetch-urls.nix: unknown JSON configuration fields for ${name}:
        ${concatStringsSep ", " unknownJsonFields}
        Allowed fields: key, filter
      ''

    else if isVersion && jsonKey != "version" then
      throw "fetch-urls.nix: VERSION must use JSON key \"version\""

    else if hasJson && !isVersion && !validOutputKey jsonKey then
      throw "fetch-urls.nix: ${name}.json.key must be a valid non-empty JSON key"

    else if shouldPersist && (!builtins.isString jsonFilter || jsonFilter == "") then
      throw "fetch-urls.nix: ${name}.json.filter must be a non-empty jq expression"

    else
      {
        inherit command;
        json = normalizedJson;
      };

  templateNames = map toUpper (attrNames templateCommands);

  duplicateTemplateNames = builtins.filter (
    name: builtins.length (builtins.filter (other: other == name) templateNames) > 1
  ) (lib.unique templateNames);

  invalidTemplateNames = builtins.filter (
    name: builtins.match "[A-Z_][A-Z0-9_]*" name == null
  ) templateNames;

  normalizedTemplateCommands =
    if !(builtins.elem "VERSION" templateNames) then
      throw "fetch-urls.nix: templateCommands must define VERSION"

    else if duplicateTemplateNames != [ ] then
      throw ''
        fetch-urls.nix: duplicate template variable names:
        ${concatStringsSep ", " duplicateTemplateNames}
      ''

    else if invalidTemplateNames != [ ] then
      throw ''
        fetch-urls.nix: invalid template variable names:
        ${concatStringsSep ", " invalidTemplateNames}
      ''

    else
      lib.mapAttrs' (name: value: {
        name = toUpper name;
        value = normalizeTemplateCommand name value;
      }) templateCommands;

  normalizeHashConfig =
    system: value:
    let
      cfg =
        if builtins.isString value then
          { urls = [ value ]; }
        else if builtins.isList value then
          { urls = value; }
        else
          value;

      isAttrs = builtins.isAttrs cfg;

      urls = if isAttrs && builtins.hasAttr "urls" cfg then cfg.urls else [ ];

      hashKey = if isAttrs then cfg.hashKey or "${system}-hash" else null;

      unknownFields =
        if isAttrs then
          builtins.filter (
            field:
            !(builtins.elem field [
              "urls"
              "hashKey"
            ])
          ) (attrNames cfg)
        else
          [ ];

      validUrls =
        builtins.isList urls && urls != [ ] && builtins.all (url: builtins.isString url && url != "") urls;
    in
    if !isAttrs then
      throw "fetch-urls.nix: invalid hashUrls configuration for ${system}"

    else if unknownFields != [ ] then
      throw ''
        fetch-urls.nix: unknown hashUrls fields for ${system}:
        ${concatStringsSep ", " unknownFields}
      ''

    else if !validUrls then
      throw "fetch-urls.nix: ${system}.urls must be a non-empty list of non-empty strings"

    else if !validOutputKey hashKey then
      throw "fetch-urls.nix: invalid hashKey for ${system}"

    else
      {
        inherit urls hashKey;
      };

  normalised = lib.mapAttrs normalizeHashConfig hashUrls;

  persistedTemplateCommands = lib.filterAttrs (
    _name: cfg: cfg.json != null
  ) normalizedTemplateCommands;

  otherTemplateCommands = builtins.removeAttrs normalizedTemplateCommands [ "VERSION" ];

  persistedOtherTemplateCommands = lib.filterAttrs (
    _name: cfg: cfg.json != null
  ) otherTemplateCommands;

  runtimeTemplateCommands = lib.filterAttrs (_name: cfg: cfg.json == null) otherTemplateCommands;

  versionCommand = normalizedTemplateCommands.VERSION.command;

  renderTemplateCommand =
    name: cfg:
    let
      variable = shellParameter name;
    in
    ''
      if ! ${name}="$(
        ${cfg.command}
      )"; then
        ${log "ERROR" "Failed to execute ${name} command"}
        exit 1
      fi

      if [ -z "${variable}" ]; then
        ${log "ERROR" "Template variable ${name} is empty"}
        exit 1
      fi

      ${log "DEBUG" (name + " command output: <" + variable + ">")}

      export ${name}
    '';

  renderJsonValue =
    name: cfg:
    let
      variable = shellParameter name;

      jsonVariableName = "_TEMPLATE_JSON_${name}";

      jsonVariable = shellParameter jsonVariableName;

      jqProgram = ''
        [ (${cfg.json.filter}) ] as $results
        | if ($results | length) != 1 then
            error("filter must produce exactly one result")
          elif ($results[0] | type) != "string" then
            error("filter must produce a string")
          else
            $results[0]
          end
      '';
    in
    ''
      if ! ${jsonVariableName}=$(
        printf '%s' "${variable}" |
          jq \
            --raw-input \
            --slurp \
            --raw-output \
            --exit-status \
            ${lib.escapeShellArg jqProgram}
      ); then
        ${log "ERROR" "Failed to format ${name} for JSON"}
        exit 1
      fi

      ${log "DEBUG" (name + " JSON value: <" + jsonVariable + ">")}
    '';

  persistedTemplateVarLines = mapAttrsToList (name: cfg: ''
    ${renderTemplateCommand name cfg}
    ${renderJsonValue name cfg}
  '') persistedOtherTemplateCommands;

  templateMetadataChecks = mapAttrsToList (
    name: cfg:
    let
      jsonVariable = shellParameter "_TEMPLATE_JSON_${name}";
    in
    ''
      if ! jq -e \
        --arg key ${lib.escapeShellArg cfg.json.key} \
        --arg value "${jsonVariable}" \
        '.[$key] == $value' \
        "${versionFile}" >/dev/null 2>&1; then
        NEEDS_UPDATE=1
      fi
    ''
  ) persistedOtherTemplateCommands;

  runtimeTemplateVarLines = mapAttrsToList (
    name: cfg: renderTemplateCommand name cfg
  ) runtimeTemplateCommands;

  prefetchBlock =
    system:
    if prefetchUnpack then
      ''
        _PREFETCH_LOG=$(mktemp "$tmpdir/prefetch.XXXXXX")
        _SRI_LOG=$(mktemp "$tmpdir/sri.XXXXXX")

        ${log "INFO" (system + ": prefetching $_URL")}

        if _NIX_HASH=$(
          nix-prefetch-url --unpack --type sha256 "$_URL" 2>"$_PREFETCH_LOG"
        ); then

          if _SRI_HASH=$(
            nix-hash --to-sri --type sha256 "$_NIX_HASH" 2>"$_SRI_LOG"
          ); then

            if [[ "$_SRI_HASH" =~ ^sha256-[A-Za-z0-9+/]{43}=$ ]]; then
              _HASH="$_SRI_HASH"
              ${log "INFO" (system + ": hash calculated successfully")}
            else
              ${log "ERROR" (system + ": invalid SRI hash: $_SRI_HASH")}
            fi

          else
            _SRI_STATUS=$?
            ${log "ERROR" (system + ": nix-hash conversion failed (exit $_SRI_STATUS)")}
            cat "$_SRI_LOG" >&2
          fi

        else
          _PREFETCH_STATUS=$?
          ${log "ERROR" (system + ": nix-prefetch-url failed (exit $_PREFETCH_STATUS)")}
          cat "$_PREFETCH_LOG" >&2
        fi

        rm -f "$_PREFETCH_LOG" "$_SRI_LOG"
      ''
    else
      ''
        _DOWNLOAD_FILE=$(mktemp "$tmpdir/download.XXXXXX")
        _HASH_LOG=$(mktemp "$tmpdir/hash.XXXXXX")
        _SRI_LOG=$(mktemp "$tmpdir/sri.XXXXXX")

        _ATTEMPT=0
        _MAX_ATTEMPTS=8
        _RESUME=1
        _DOWNLOAD_OK=0

        while [ "$_ATTEMPT" -lt "$_MAX_ATTEMPTS" ]; do
          _ATTEMPT=$((_ATTEMPT + 1))

          _CURL_RESUME_ARGS=()

          if [ "$_RESUME" -eq 1 ] && [ -s "$_DOWNLOAD_FILE" ]; then
            _CURL_RESUME_ARGS=(--continue-at -)

            ${log "INFO" (system + ": resuming download (attempt $_ATTEMPT/$_MAX_ATTEMPTS)")}
          else
            ${log "INFO" (system + ": downloading $_URL (attempt $_ATTEMPT/$_MAX_ATTEMPTS)")}

            if [ "$_RESUME" -eq 0 ]; then
              : > "$_DOWNLOAD_FILE"
            fi
          fi

          if _HTTP_CODE=$(
            ${curl}/bin/curl \
              --fail \
              --location \
              --progress-bar \
              --show-error \
              --connect-timeout 30 \
              "''${_CURL_RESUME_ARGS[@]}" \
              --output "$_DOWNLOAD_FILE" \
              --write-out '%{http_code}' \
              "$_URL"
          ); then
            _DOWNLOAD_OK=1
            ${log "INFO" (system + ": download completed (HTTP $_HTTP_CODE)")}
            break

          else
            _CURL_STATUS=$?
            _HTTP_CODE=''${_HTTP_CODE:-000}

            ${log "WARN" (system + ": curl failed (exit $_CURL_STATUS, HTTP $_HTTP_CODE)")}

            if [ "$_CURL_STATUS" -eq 33 ] && [ "$_RESUME" -eq 1 ]; then
              ${log "WARN" (system + ": server rejected Range; restarting from byte zero")}

              _RESUME=0
              : > "$_DOWNLOAD_FILE"
              continue
            fi

            _SHOULD_RETRY=0

            case "$_CURL_STATUS" in
              5|6|7|16|18|28|35|52|55|56|92)
                _SHOULD_RETRY=1
                ;;
              22)
                case "$_HTTP_CODE" in
                  408|425|429|500|502|503|504|522|524)
                    _SHOULD_RETRY=1
                    ;;
                esac
                ;;
            esac

            if [ "$_SHOULD_RETRY" -eq 0 ]; then
              ${log "ERROR" (system + ": non-retryable download error")}
              break
            fi

            if [ "$_ATTEMPT" -ge "$_MAX_ATTEMPTS" ]; then
              ${log "ERROR" (system + ": maximum download attempts reached")}
              break
            fi

            _PARTIAL_SIZE=$(
              ${coreutils}/bin/wc -c < "$_DOWNLOAD_FILE" |
                ${coreutils}/bin/tr -d '[:space:]'
            )

            ${log "WARN" (system + ": preserving $_PARTIAL_SIZE downloaded bytes")}

            _RETRY_DELAY=$((2 ** (_ATTEMPT - 1)))

            if [ "$_RETRY_DELAY" -gt 30 ]; then
              _RETRY_DELAY=30
            fi

            ${log "INFO" (system + ": retrying in $_RETRY_DELAY seconds...")}
            ${coreutils}/bin/sleep "$_RETRY_DELAY"
          fi
        done

        if [ "$_DOWNLOAD_OK" -eq 1 ]; then
          if [ ! -s "$_DOWNLOAD_FILE" ]; then
            ${log "ERROR" (system + ": download completed but file is empty")}

          else
            if _NIX_HASH=$(
              nix-hash \
                --type sha256 \
                --flat \
                --base32 \
                "$_DOWNLOAD_FILE" 2>"$_HASH_LOG"
            ); then

              if _SRI_HASH=$(
                nix-hash --to-sri --type sha256 "$_NIX_HASH" 2>"$_SRI_LOG"
              ); then

                if [[ "$_SRI_HASH" =~ ^sha256-[A-Za-z0-9+/]{43}=$ ]]; then
                  _HASH="$_SRI_HASH"
                  ${log "INFO" (system + ": hash calculated successfully")}
                else
                  ${log "ERROR" (system + ": invalid SRI hash: $_SRI_HASH")}
                fi

              else
                _SRI_STATUS=$?
                ${log "ERROR" (system + ": SRI conversion failed (exit $_SRI_STATUS)")}
                cat "$_SRI_LOG" >&2
              fi

            else
              _HASH_STATUS=$?
              ${log "ERROR" (system + ": nix-hash failed (exit $_HASH_STATUS)")}
              cat "$_HASH_LOG" >&2
            fi
          fi

        else
          ${log "ERROR" (system + ": download could not be completed")}
        fi

        rm -f \
          "$_DOWNLOAD_FILE" \
          "$_HASH_LOG" \
          "$_SRI_LOG"
      '';

  templateMetadataCommands = lib.mapAttrs' (
    name: cfg:
    let
      jsonVariable = shellParameter "_TEMPLATE_JSON_${name}";
    in
    {
      name = cfg.json.key;
      value = ''printf '%s\n' "${jsonVariable}"'';
    }
  ) persistedTemplateCommands;

  hashCommands = lib.mapAttrs' (system: cfg: {
    name = cfg.hashKey;
    value = ''printf '%s\n' "$_HASH_${sanitize system}"'';
  }) normalised;

  metadataOutputKeys = mapAttrsToList (_name: cfg: cfg.json.key) persistedTemplateCommands;

  hashOutputKeys = mapAttrsToList (_system: cfg: cfg.hashKey) normalised;

  allOutputKeys = metadataOutputKeys ++ hashOutputKeys;

  invalidOutputKeys = builtins.filter (key: !validOutputKey key) allOutputKeys;

  safeOutputKeys = map safeOutputKey (builtins.filter builtins.isString allOutputKeys);

  duplicateOutputKeys = builtins.filter (
    key: builtins.length (builtins.filter (other: other == key) safeOutputKeys) > 1
  ) (lib.unique safeOutputKeys);

  commands =
    if invalidOutputKeys != [ ] then
      throw "fetch-urls.nix: invalid JSON output keys"

    else if duplicateOutputKeys != [ ] then
      throw ''
        fetch-urls.nix: JSON output keys collide after Shell normalization:
        ${concatStringsSep ", " duplicateOutputKeys}
      ''

    else
      templateMetadataCommands // hashCommands;

  preScript = ''
    set -euo pipefail

    export PATH="${
      lib.makeBinPath [
        curl
        coreutils
      ]
    }:$PATH"

    # 1. Determine VERSION.
    if ! VERSION="$(
      ${versionCommand}
    )"; then
      ${log "ERROR" "Failed to determine VERSION"}
      exit 1
    fi

    if [ -z "$VERSION" ]; then
      ${log "ERROR" "VERSION is empty"}
      exit 1
    fi

    export VERSION

    # 2. Format persisted template variables.
    ${renderJsonValue "VERSION" normalizedTemplateCommands.VERSION}
    ${concatStringsSep "\n    " persistedTemplateVarLines}

    # 3. Check existing metadata.
    CURRENT_VERSION=$(jq -r '.version // empty' "${versionFile}" 2>/dev/null || true)
    NEEDS_UPDATE=0

    if [ "$_TEMPLATE_JSON_VERSION" != "$CURRENT_VERSION" ]; then
      NEEDS_UPDATE=1
    fi

    ${concatStringsSep "\n    " templateMetadataChecks}

    # 4. Check existing hashes.
    ${concatStringsSep "\n    " (
      mapAttrsToList (system: cfg: ''
        if ! jq -e \
          --arg key ${lib.escapeShellArg cfg.hashKey} \
          --arg ph "${placeholderHash}" \
          '.[$key] | strings | select(
            . != "" and
            . != $ph and
            test("^sha256-[A-Za-z0-9+/]{43}=$")
          )' \
          "${versionFile}" >/dev/null 2>&1; then
          NEEDS_UPDATE=1
        fi
      '') normalised
    )}

    # 5. Reuse existing JSON when nothing needs updating.
    if [ "$NEEDS_UPDATE" -eq 0 ]; then
      cat "${versionFile}"
      exit 0
    fi

    if [ "$_TEMPLATE_JSON_VERSION" = "$CURRENT_VERSION" ]; then
      ${log "INFO" "Persisted metadata or hashes changed, recomputing..."}
    else
      ${log "INFO" "Version changed ($CURRENT_VERSION -> $_TEMPLATE_JSON_VERSION), recomputing..."}
    fi

    # 6. Execute runtime-only template commands.
    ${concatStringsSep "\n    " runtimeTemplateVarLines}

    # 7. Prepare temporary storage.
    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT

    # 8. Resolve URLs and calculate hashes.
    ${concatStringsSep "\n    " (
      mapAttrsToList (system: cfg: ''
        _HASH=""

        ${concatStringsSep "\n        " (
          builtins.map (url: ''
            if [ -z "$_HASH" ]; then
              _URL_TEMPLATE=${lib.escapeShellArg url}
              _URL="$_URL_TEMPLATE"

              ${log "DEBUG" (system + " URL template: <$_URL_TEMPLATE>")}

              ${concatStringsSep "\n                  " (
                mapAttrsToList (
                  name: _:
                  let
                    variable = shellParameter name;
                  in
                  ''
                    _URL="''${_URL//"@${name}@"/"${variable}"}"
                  ''
                ) normalizedTemplateCommands
              )}

              if [[ "$_URL" =~ @([A-Za-z_][A-Za-z0-9_]*)@ ]]; then
                _UNRESOLVED_VARIABLE=''${BASH_REMATCH[1]}
                ${log "ERROR" (system + " undefined template variable: @$_UNRESOLVED_VARIABLE@")}
                exit 1
              fi

              ${log "DEBUG" (system + " URL after replacement: <$_URL>")}
              ${log "INFO" (system + " resolved URL: $_URL")}

              ${prefetchBlock system}
            fi
          '') cfg.urls
        )}

        if [ -z "$_HASH" ]; then
          ${log "ERROR" (system + ": all candidate URLs failed")}
          exit 1
        fi

        printf '%s\n' "$_HASH" > "$tmpdir/${system}"
      '') normalised
    )}

    # 9. Export calculated hashes for mk-json.
    ${concatStringsSep "\n    " (
      mapAttrsToList (system: _: ''
        _HASH_${sanitize system}=$(cat "$tmpdir/${system}")
      '') normalised
    )}

    # 10. Run optional preprocessing.
    ${extraPreScript}
  '';

in
callPackage ./json.nix {
  inherit preScript commands;
}
