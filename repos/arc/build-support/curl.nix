{ self, ... }: let builders = {
  fetchCurlJson = { stdenvNoCC, lib, curl, sourceBashArray, cacert ? null, jq ? null }: { curlUrl, curlHeaders ? {}, curlOptions ? [], jqFilter ? null, sha256, env ? { }, name ? "fetch-curl-json" }: with lib; let
    curlHeaders' = mapAttrsToList (h: v: [ "-H" "${h}: ${v}" ])
      (foldAttrList [ { User-Agent = "arcnmx-nix-channel"; } curlHeaders ]);
    curlOptions' = (flatten curlHeaders') ++ curlOptions;
    env' = builtins.removeAttrs env [ "passthru" ];
    package = assert jqFilter == null -> jq != null; stdenvNoCC.mkDerivation ({
      inherit name curlUrl;
      outputHashMode = "flat";
      outputHashAlgo = "sha256";
      outputHash = sha256;
      nativeBuildInputs = [curl cacert] ++
        optional (jqFilter != null) jq;
      curlOptions = sourceBashArray "CURL_OPTS" curlOptions';
      jqFilter = if jqFilter != null then sourceBashArray "JQ_OPTS" (toList jqFilter) else null;
      unpackPhase = ''
        source $curlOptions

        jq_filter() {
          if [[ -n $jqFilter ]]; then
            source $jqFilter
            jq -Mec "''${JQ_OPTS[@]}"
          else
            cat
          fi
        }
      '';

      buildPhase = ''
        curl -LSsf "$curlUrl" -o out.json "''${CURL_OPTS[@]}"
      '';

      installPhase = ''
        jq_filter < out.json > $out
      '';

      passthru = env.passthru or {} // rec {
        contents = builtins.readFile package.out;
        json = builtins.fromJSON contents;
      };
    } // env');
  in package;
  fetchGitHubApi = { fetchCurlJson, lib }: { gitHubEndpoint, gitHubOAuth2Token ? null, gitHubPostData ? null, sha256, jqFilter ? null, name ? "fetch-github-json", env ? {} }@args: with lib; let
    curlHeaders = optionalAttrs (gitHubOAuth2Token != null) { Authorization = "token ${gitHubOAuth2Token}"; };
    curlUrl = "https://api.github.com/${gitHubEndpoint}";
    curlOptions = if gitHubPostData != null then ["-d" (builtins.toJSON gitHubPostData)] else [];
    env = args.env or {} // {
      inherit gitHubOAuth2Token;
      impureEnvVars = ["GITHUB_TOKEN"];
      configurePhase = ''
        if [[ -z $gitHubOAuth2Token && -n $GITHUB_TOKEN ]]; then
          CURL_OPTS+=(-H "Authorization: token $GITHUB_TOKEN")
        fi
      '';
      passthru = args.env.passthru or {} // {
        ci = args.env.passthru.ci or {} // {
          skip = if gitHubOAuth2Token == null && builtins.getEnv "GITHUB_TOKEN" == "" then "no token" else false;
        };
      };
    };
  in fetchCurlJson { inherit curlHeaders curlUrl jqFilter sha256 name env; };
};
in builtins.mapAttrs (_: p: self.callPackage p { }) builders
