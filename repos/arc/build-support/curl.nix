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
};
in builtins.mapAttrs (_: p: self.callPackage p { }) builders
