{ lib }:

let

  replaceStringsInOrder = (replacements: input:
    if builtins.length replacements == 0 then input else
    let
      a = builtins.elemAt replacements 0;
      b = builtins.elemAt replacements 1;
      input2 = builtins.replaceStrings [a] [b] input;
      r2 = builtins.tail (builtins.tail replacements);
    in
    replaceStringsInOrder r2 input2
  );

  fromYAML = (input:
    #builtins.trace "fromYAML input ${builtins.toJSON input}"
    (
    let
      #blocks = lib.flatten (builtins.split "\n\n" input); # wrong
      lines1 = lib.flatten (builtins.split "\n" input);
      # remove empty lines # TODO escape and preserve empty lines
      lines2 = builtins.filter (line: line != "") lines1;
      # remove comment lines
      lines3 = builtins.filter (line: (builtins.substring 0 1 line) != "#") lines2;
      input2 = builtins.concatStringsSep "\n" lines3;
      # escape indents of sub-blocks
      input3 = builtins.replaceStrings ["\n  "] ["\t  "] input2;
      # split blocks
      blocks1 = lib.flatten (builtins.split "\n" input3);
      # unescape indents of sub-blocks
      blocks2 = map (input: builtins.replaceStrings ["\t  "] ["\n  "] input) blocks1;

      dedent = input: builtins.replaceStrings ["\n  "] ["\n"] input;

      parseList = (blocks:
        #{ list = blocks; }
        map (input: fromYAML (builtins.substring 1 9999999 input)) blocks
      );

      parseMap = (blocks:
        builtins.listToAttrs (builtins.filter (x: x != null) (map parseItem blocks))
      );

      parseInlineMap = (input:
        builtins.trace "parseInlineMap input ${builtins.toJSON input}"
        parseMap (lib.flatten (builtins.split ", " input))
        #{ inlineMap = input; }
        #builtins.listToAttrs (builtins.filter (x: x != null) (map parseItem blocks))
      );

      parseItem = input: (
        builtins.trace "parseItem input ${builtins.toJSON input}"
        (
        let
          name1 = builtins.head (builtins.split ":" input); # wasteful...
          name2 = parseString name1;
          value1 = builtins.substring ((builtins.stringLength name1) + 1) 999999 input;
        in
        { name = name2; value = fromYAML (dedent value1); }
        )
      );

      toFloat = (s:
        if builtins.match "[[:space:]]*(-?([[:digit:]]+\.[[:digit:]]*|[[:digit:]]*\.[[:digit:]]+)([eE][[:digit:]]+)?)[[:space:]]*" s == null
        then throw "toFloat: not a number: ${builtins.toJSON s}" else
        builtins.fromJSON s
      );

      # TODO why is tryEval not working here
      # nix-repl> let toFloat = s: let r = builtins.tryEval (builtins.fromJSON s); in if (r.success == false || (builtins.typeOf r.value != "float" && builtins.typeOf r.value != "int")) then throw "not a number: ${builtins.toJSON s}" else r.value; in toFloat "1.23x"

      parseValue = (input:
        builtins.trace "parseValue input ${builtins.toJSON input}"
        (
        #if input == "true" then true else
        #if input == "false" then false else
        let
          spaceMatches = builtins.match "[[:space:]]*" input;
          trueMatches = builtins.match "[[:space:]]*true[[:space:]]*" input;
          falseMatches = builtins.match "[[:space:]]*false[[:space:]]*" input;
          intMatches = builtins.match "[[:space:]]*(-?[[:digit:]]+)[[:space:]]*" input;
          floatMatches = builtins.match "[[:space:]]*(-?([[:digit:]]+\\.[[:digit:]]*|[[:digit:]]*\\.[[:digit:]]+|[[:digit:]]+)([eE][[:digit:]]+)?)[[:space:]]*" input;
          #numberMatches = builtins.match "[[:space:]]*(-?([[:digit:]]+\.[[:digit:]]*|[[:digit:]]*\.[[:digit:]]+)([eE][[:digit:]]+)?)[[:space:]]*" input;
        in
        if spaceMatches != null then null else
        if trueMatches != null then true else
        if falseMatches != null then false else
        if intMatches != null then builtins.fromJSON input else
        if floatMatches != null then builtins.fromJSON input else
        parseString input
        )
      ); # TODO recurse?

      # TODO decode backslash escapes \" \' \n \\ ...
      # TODO use unquote from nix-parsec?
      parseString = (input:
        let
          matches1 = builtins.match "[[:space:]]*'(.*)'[[:space:]]*" input;
          matches2 = builtins.match "[[:space:]]*\"(.*)\"[[:space:]]*" input;
          matches3 = builtins.match "[[:space:]]*(.*[^[:space:]])[[:space:]]*" input;
        in
        if matches1 != null then builtins.head matches1 else
        if matches2 != null then builtins.head matches2 else
        if matches3 != null then builtins.head matches3 else
        input
      );

      firstLine = builtins.head lines3;

      inlineMapMatches = builtins.match "[[:space:]]*[{](.*)[}][[:space:]]*" firstLine;

    in
    (
      #input2
      #input3
      #blocks1
      #blocks2
      if (builtins.substring 0 1 input2) == "-" then parseList blocks2 else
      if (inlineMapMatches != null) then parseInlineMap (builtins.head inlineMapMatches) else
      #if (builtins.match ".*:.*" firstLine # TODO regex?
      #if (builtins.length (builtins.split ":" firstLine) == 3) then parseMap blocks2 else
      #if (builtins.length (builtins.split ":" firstLine) > 1) then parseMap blocks2 else
      if (
        #builtins.length (builtins.split ":\n" firstLine) > 1 ||
        builtins.match ".*:" firstLine != null ||
        builtins.length (builtins.split ": " firstLine) > 1
      ) then parseMap blocks2 else
      parseValue input
    )
    )
  );


  fromYAMLZZ2 = (input:
    let
      blocks = lib.flatten (builtins.split "\n\n" input); # wrong
      lines = lib.flatten (builtins.split "\n" input);
      #matchBlock = builtins.match "\n  /([^ ]+):\n(    .*)\n\n";
      matchPnameVersion = builtins.match "  /([^ ]+):"; # "  /source-map-js@1.2.0:" -> [ "source-map-js@1.2.0" ]
      matchPnameVersionSplit = builtins.match "  /([^ ]+)@([^ ]+):"; # "  /source-map-js@1.2.0:" -> [ "source-map-js" "1.2.0" ]

/*
    resolution: {integrity: sha512-itJW8lvSA0TXEphiRoawsCksnlf8SyvmFzIhltqAHluXd88pkCd+cXJVHTDwdCr0IzwptSm035IHQktUu1QUMg==}
    engines: {node: '>=0.10.0'}
    dev: true
*/
      parseLine = (input:
        let matches = builtins.match "    ([^ ]+): (.+)" input; in
        if matches == null then null else
        (
        let
          name = builtins.head matches;
          value = builtins.elemAt matches 1;
          parseBool = input: if input == "true" then true else false;
          parseList = (input:
            let matches = builtins.match "[[]([^][]*)[]]" input; in
            if matches == null then input else # dont parse
            lib.flatten (builtins.split " " (builtins.head matches))
          );
          parseMap = (input:
            #builtins.trace "parseMap input ${builtins.toJSON input}"
            (
            let matches = builtins.match "[{]([^}{]*)[}]" input; in
            if matches == null then input else # dont parse
            let items = lib.flatten (builtins.split ", " (builtins.head matches)); in
            builtins.listToAttrs (builtins.filter (x: x != null) (map parseItem items))
            )
          );
          parseItem = (input:
            let matches = builtins.match "([^ ]+): (.*)" input; in
            #if matches == null then input else # dont parse
            if matches == null then { name = input; value = null; } else # dont parse
            (
            {
              name = builtins.head matches;
              value = parseString (builtins.elemAt matches 1);
            }
            )
          );
          # TODO decode backslash escapes \" \' \n \\ ...
          # TODO use unquote from nix-parsec?
          parseString = (input:
            let
              matches1 = builtins.match "'(.*)'" input;
              matches2 = builtins.match "\"(.*)\"" input;
            in
            if matches1 != null then builtins.head matches1 else
            if matches2 != null then builtins.head matches2 else
            input
          );
        in
/*
    "cpu": "[x64]",
    "dev": "true",
    "engines": "{node: '>=12'}",
    "optional": "true",
    "os": "[android]",
    "requiresBuild": "true",
    "resolution": "{integrity: sha512-8GDdlePJA8D6zlZYJV/jnrRAi6rOiNaCC/JclcXpB+KIuvfBN4owLtgzY2bsxnx666XjJx2kDPUmnTtR8qKQUg==}"
*/
        {
          inherit name;
          value = (
            if (builtins.elem name ["dev" "optional" "hasBin" "requiresBuild"]) then parseBool value else
            if (builtins.elem name ["cpu" "os"]) then parseList value else
            if (builtins.elem name ["resolution" "engines"]) then parseMap value else
            value
          );
        }
        )
      );

      /*
      note: sub-blocks are not parsed
      this would require recursive non-greedy matching of the pattern "\n  (.*?)
      but builtins.match does not support non-greedy matching...
      TODO nix builtins.match non-greedy matching
      example: peerDependencies, dependencies, transitivePeerDependencies
        /@vitejs/plugin-react@3.1.0(vite@4.5.3):
          resolution: {integrity: sha512-AfgcRL8ZBhAlc3BFdigClmTUMISmmzHn7sB2h9U1odvc5U/MjWXsAaz18b/WoppUTDBzxOJwo2VdClfUcItu9g==}
          engines: {node: ^14.18.0 || >=16.0.0}
          peerDependencies:
            vite: ^4.1.0-beta.0
          dependencies:
            '@babel/core': 7.24.5
            '@babel/plugin-transform-react-jsx-self': 7.24.5(@babel/core@7.24.5)
            '@babel/plugin-transform-react-jsx-source': 7.24.1(@babel/core@7.24.5)
            magic-string: 0.27.0
            react-refresh: 0.14.2
            vite: 4.5.3(@types/node@18.19.33)
          transitivePeerDependencies:
            - supports-color
          dev: true
      */

      parseBlock = (input:
        let
          lines = lib.flatten (builtins.split "\n" input);
          line0 = builtins.head lines;
          #line0 = builtins.head (builtins.match "([^\n]+)\n.*" input); # match can return null
          inputRest = builtins.substring ((builtins.stringLength line0) + 1) 9999999 input;
          # escape indent of sub-blocks
          #inputRest2 = builtins.replaceStrings ["\n    "] ["\n____"] inputRest;
          inputRest2 = builtins.replaceStrings ["\n    "] ["\r    "] inputRest;
          # unescape indent of sub-blocks, remove indent "  "
          subBlocks = map (input: builtins.replaceStrings ["\r    " "\n  "] ["\n    " "\n"] input) (builtins.split "\n  " inputRest2);
          # TODO call parseBlock
          linesRest = builtins.tail lines;
          name = matchPnameVersion line0;
        in
        #builtins.trace "input ${builtins.toJSON input} -> name ${builtins.toJSON name}"
        builtins.trace "input ${builtins.toJSON input} -> inputRest ${builtins.toJSON inputRest}"
        #if builtins.length lines == 1 then parseLine input else
        (
        if name == null then null else
        {
          # note: name can be more complex than pname@version, for example
          #   "@babel/plugin-transform-react-jsx-self@7.24.5(@babel/core@7.24.5)"
          #   "react-use@17.5.0(react-dom@18.3.1)(react@18.3.1)"
          name = builtins.head name;
          #value = builtins.listToAttrs (builtins.filter (x: x != null) (map parseLine linesRest));
          #value = builtins.listToAttrs (builtins.filter (x: x != null) (map parseBlock subBlocks));
          value = (
            if builtins.length lines == 1 then parseLine input else
            builtins.listToAttrs (builtins.filter (x: x != null) (map parseBlock subBlocks))
          );
        }
        )
      );
    in
    builtins.listToAttrs (builtins.filter (x: x != null) (map parseBlock blocks))
  );

  fromYAMLZZZ = (input:
    # builtins.fromJSON # TODO
    (
      "{" +
      (replaceStringsInOrder
      [
        /*
        "\nlockfileVersion:"
        "\n\"lockfileVersion\":"

        "\nsettings:"
        "\n\"settings\":{"

        "\n  autoInstallPeers:"
        "\n  \"autoInstallPeers\":"

        "\n  excludeLinksFromLockfile:"
        "\n  \"excludeLinksFromLckfile\":"

        "\noverrides:"
        "\n\"overrides\":"

        ": \""
        ": \"\""

        ": "
        ": \""

        ": \"\"\""
        ": \""

        "'"
        "\\'"

        "\n\n"
        "},"

        "\n"
        "\",\n"

        "},"
        "},\n"

        "\"false\""
        "false"

        "\"true\""
        "true"
        */

        "\nl" "\n\"l"
        "\ns" "\n\"s"
        "\no" "\n\"o"
        "\nd" "\n\"d"

        "'" "\""

        "\n    \""     "\n    \"\""
        "\n    "       "\n    \""
        "\n    \"\"\"" "\n    \""

        "\n  \""     "\n  \"\""
        "\n  "       "\n  \""
        "\n  \"\"\"" "\n  \""

        "\n  \"  \"" "\n    \""

        "\": "     "\"\": "
        ": "       "\": "
        "\"\"\": " "\": "

        ": \""     ": \"\""
        ": "       ": \""
        ": \"\"\"" ": \""

        ":\n  " ": {\n  "

        "\n  " "\"\n"
        ": {\"\n  " ": {\n"

      ]
      /*
      builtins.replaceStrings
      [
        "\nlockfileVersion:"
        "\nsettings:"
        "\n  autoInstallPeers:"
        "\n  excludeLinksFromLockfile:"
        "\noverrides:"
        ": \""
        ": "
        ": \"\"\""
        "'"
        "\n\n"
        "\n"
        "},"
      ]
      [
        "\n\"lockfileVersion\":"
        "\n\"settings\":{"
        "\n  \"autoInstallPeers\":"
        "\n  \"excludeLinksFromLckfile\":"
        "\n\"overrides\":"
        ": \"\""
        ": \""
        ": \""
        "\\'"
        "},"
        "\",\n"
        "},\n"
      ]
      */
      (
        "\n" +
        input +
        #(builtins.substring 0 200 (builtins.readFile ./pnpm-lock.yaml)) +
        "\n"
      )
    ) +
    "}")
  );
in

fromYAML
