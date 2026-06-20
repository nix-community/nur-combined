{ pkgs }:

rec {

  convertWasmToWat = pkgs.writeShellApplication {
    name = "convert-wasm-to-wat";
    passthru = {
      fromSuffix = ".wasm";
      toSuffix = ".wat";
    };
    runtimeInputs = [ pkgs.wabt ];
    text = ''
      exec wasm2wat "$@"
    '';
  };

  convertWatToWasm = pkgs.writeShellApplication {
    name = "convert-wat-to-wasm";
    passthru = {
      fromSuffix = ".wat";
      toSuffix = ".wasm";
    };
    runtimeInputs = [ pkgs.wabt ];
    text = ''
      exec wat2wasm "$@" --output=-
    '';
  };

  convertWasmToText = pkgs.writeShellApplication {
    name = "convert-wasm-to-text";
    passthru = {
      fromSuffix = ".wasm";
      toSuffix = ".txt";
    };
    runtimeInputs = [ pkgs.wabt ];
    text = ''
      exec wasm-objdump -x "$1"
    '';
  };

  convertWasmToJson = pkgs.writeShellApplication {
    name = "convert-wasm-to-json";
    passthru = {
      fromSuffix = ".wasm";
      toSuffix = ".json";
    };
    runtimeInputs = [
      convertWasmToText
      pkgs.python3
    ];
    text = ''
      convert-wasm-to-text "$1" | python3 -c '
      import json, sys, re

      text = sys.stdin.read()
      lines = text.split("\n")

      result = {}

      # "filename:    file format wasm 0x1"
      m = re.match(r"^(.+?):\s+file format (.+)$", lines[0])
      if m:
          result["file"] = m.group(1).strip()
          result["format"] = m.group(2).strip()

      sections = []
      current = None

      for line in lines[1:]:
          stripped = line.strip()
          if not stripped or stripped == "Section Details:":
              continue

          # Section header like "Type[2]:"
          m = re.match(r"^(\w+)\[(\d+)\]:", stripped)
          if m:
              if current:
                  sections.append(current)
              current = {
                  "section": m.group(1),
                  "count": int(m.group(2)),
                  "items": []
              }
              continue

          if current is not None and stripped:
              current["items"].append(stripped)

      if current:
          sections.append(current)

      result["sections"] = sections
      print(json.dumps(result, indent=2))
      '
    '';
  };

}
