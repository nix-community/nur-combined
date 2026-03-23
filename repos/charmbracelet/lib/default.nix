{ pkgs }:

with pkgs.lib;
let
  jsonFormat = pkgs.formats.json { };
in
rec {
  /**
    Recursively clean an attribute set for JSON serialization by removing all `null` values and any attribute sets that become empty as a result.

    Nix module options declared with `default = null` or `default = { }` are always present in the evaluated config, even when the user never sets them.
    Passing such a config through `builtins.toJSON` produces explicit `null` entries and empty objects in the output.
    Downstream applications may misinterpret these as intentionally configured values
    — for example, an empty `"oauth": {}` block causes Crush to attempt an OAuth token refresh on providers that don't support it.

    # Inputs
    `value` : The value to clean. Typically an attribute set, but any Nix value is accepted and non-attrset, non-list values are returned as-is.

    # Type
    ```
    removeNulls :: a -> a
    ```

    # Examples
    :::{.example}
    ## `charmLib.removeNulls` usage example

    ```nix
    removeNulls {
      name = "Ollama";
      api_key = null;
      oauth = { access_token = null; refresh_token = null; };
      models = [{ id = "qwen3:8b"; cost_per_1m_in = null; }];
    }
    => {
      name = "Ollama";
      models = [{ id = "qwen3:8b"; }];
    }
    ```
    :::
  */
  removeNulls =
    let
      clean =
        value:
        if builtins.isAttrs value then
          let
            filtered = filterAttrs (_: v: v != null) value;
            cleaned = mapAttrs (_: clean) filtered;
          in
          filterAttrs (_: v: !(builtins.isAttrs v && v == { })) cleaned
        else if builtins.isList value then
          map clean value
        else
          value;
    in
    clean;

  /**
    Generate a pretty-printed JSON file from an attribute set, with all `null` values and empty objects recursively removed.

    Combines `removeNulls` with `pkgs.formats.json` (which uses `jq` under the hood) to produce a human-readable, clean JSON file suitable for use as `home.file.*.source` or `environment.etc.*.source`.

    # Inputs
    `attrs` : The attribute set to serialize.

    # Type
    ```
    toCleanJSON :: AttrSet -> Derivation
    ```

    # Examples
    :::{.example}
    ## `charmLib.toCleanJSON` usage example

    ```nix
    home.file.".config/crush/crush.json".source = charmLib.toCleanJSON {
      providers.ollama = {
        name = "Ollama";
        api_key = null;
        base_url = "http://localhost:11434/v1/";
      };
    };
    ```

    Produces a pretty-printed JSON file containing:
    ```json
    {
      "providers": {
        "ollama": {
          "base_url": "http://localhost:11434/v1/",
          "name": "Ollama"
        }
      }
    }
    ```
    :::
  */
  toCleanJSON = attrs: jsonFormat.generate "settings.json" (removeNulls attrs);
}
