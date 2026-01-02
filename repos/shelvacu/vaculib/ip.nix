{ lib, vaculib, ... }:
let
  toInt = lib.toIntBase10;
  elemAt =
    list: idx:
    let
      positiveIdx = if idx < 0 then (lib.length list) + idx else idx;
    in
    lib.elemAt list positiveIdx;
  isDigits = str: (builtins.match ''[0-9]+'' str) != null;
  isHexDigits = str: (builtins.match ''[0-9a-fA-F]+'' str) != null;
  isIPAny = obj: lib.isAttrs obj && (obj._type or null) == "com.shelvacu.nix.ip";
  mkVersionDataCore =
    {
      segmentCount,
      segmentBitSize,
      versionInt,
      mkIP,
      ipToStringCore,
      innerParseStrCore,
      ...
    }@args:
    let
      this = args // {
        versionString = "IPv${toString versionInt}";
        bitSize = segmentCount * segmentBitSize;
        segmentValueMax = (vaculib.pow 2 segmentBitSize) - 1;
        maskBitsToSegment =
          bits:
          if bits <= 0 then
            0
          else if bits >= segmentBitSize then
            this.segmentValueMax
          else
            (vaculib.pow 2 bits) - 1;
        ipToString =
          obj: (ipToStringCore obj) + lib.optionalString obj.hasPrefix "/${builtins.toString obj.prefixSize}";
        isIP = obj: isIPAny obj && obj.ipVersion == versionInt;
        mkIPCore =
          {
            segments,
            prefixSize ? null,
            ...
          }@args:
          assert vaculib.isListWhere (seg: lib.isInt seg && seg >= 0 && seg <= this.segmentValueMax) segments;
          assert
            prefixSize != null -> (lib.isInt prefixSize && prefixSize >= 0 && prefixSize <= this.bitSize);
          {
            _type = "com.shelvacu.nix.ip";
            ipVersion = versionInt;
            inherit segments;
            __toString = this.ipToString;
            hasPrefix = false;
            prefixSize = null;
            toSubnet = mkIP (args // { prefixSize = this.bitSize; });
          }
          // lib.optionalAttrs (prefixSize != null) {
            hasPrefix = true;
            inherit prefixSize;
            toSubnet = mkIP args;
            subnetMask = mkIP {
              segments = lib.genList (
                idx: this.maskBitsToSegment (prefixSize - segmentBitSize * idx)
              ) segmentCount;
            };
          };
        parseStrCore =
          str:
          let
            subnetSplit = lib.splitString "/" str;
            addrStr = lib.head subnetSplit;
            subnetStr = if (lib.length subnetSplit) == 2 then elemAt subnetSplit 1 else null;
            prefixSize = if subnetStr == null then null else toInt subnetStr;
            innerParse = innerParseStrCore addrStr;
            valid =
              (subnetStr != null -> (isDigits subnetStr) && prefixSize >= 0 && prefixSize <= this.bitSize)
              && innerParse.valid;
          in
          {
            inherit valid;
          }
          // lib.optionalAttrs valid {
            mkArgs = innerParse.mkArgs // {
              inherit prefixSize;
            };
          };
        isValidStr = str: (this.parseStrCore str).valid;
        parse =
          str:
          builtins.addErrorContext
            ''While parsing ${lib.strings.escapeNixString str} as ${this.versionString}''
            (
              let
                innerParse = this.parseStrCore str;
              in
              lib.throwIf (
                !innerParse.valid
              ) "Invalid ${this.versionString} string: ${lib.strings.escapeNixString str}" mkIP innerParse.mkArgs
            );
        zero = this.mkIP { segments = lib.genList (_: 0) this.segmentCount; };
        publicMethods = {
          inherit (this)
            mkIP
            isIP
            isValidStr
            parse
            zero
            ;
        };
      };
    in
    this;
  mkVersionData =
    f:
    let
      result = mkVersionDataCore (f result);
    in
    result;
  v4Data = mkVersionData (this: {
    segmentCount = 4;
    segmentBitSize = 8;
    versionInt = 4;
    mkIP =
      args:
      (this.mkIPCore args)
      // {
        zone = null;
        hasZone = false;
      };
    ipToStringCore =
      obj:
      lib.pipe obj.segments [
        (map builtins.toString)
        (lib.concatStringsSep ".")
      ];
    innerParseStrCore =
      addrStr:
      let
        segmentStrs = lib.splitString "." addrStr;
        segments = map toInt segmentStrs;
        valid =
          (builtins.length segmentStrs) == 4
          && (lib.all isDigits segmentStrs)
          && (lib.all (s: s >= 0 && s <= this.segmentValueMax) segments);
      in
      { inherit valid; } // lib.optionalAttrs valid { mkArgs = { inherit segments; }; };
  });
  v6Data = mkVersionData (this: rec {
    segmentCount = 8;
    segmentBitSize = 16;
    versionInt = 6;
    mkIP =
      {
        zone ? null,
        ...
      }@args:
      assert zone == null || lib.isString zone;
      this.mkIPCore args
      // {
        inherit zone;
        hasZone = zone != null;
      };
    ipToStringCore =
      obj:
      (lib.pipe obj.segments [
        (map vaculib.decToHex)
        (lib.concatStringSep ":")
      ])
      + lib.optionalString obj.hasZone "%${obj.zone}";
    parseSide =
      str:
      let
        segmentStrs = lib.splitString ":" str;
        segmentStrs' = if segmentStrs == [ "" ] then [ ] else segmentStrs;
        valid = lib.all isHexDigits segmentStrs;
        segments = map vaculib.conversions.hexToDec segmentStrs';
      in
      ({ inherit valid; } // lib.optionalAttrs valid { inherit segments; });
    parsePlain =
      {
        str,
        bitsParsedSeparately ? 0,
      }:
      let
        segmentFullCount = (this.bitSize - bitsParsedSeparately) / segmentBitSize;
        sides = lib.splitString "::" str;
        compressed = lib.length sides == 2;
        leftResult = parseSide (elemAt sides 0);
        leftSegments = leftResult.segments or [ ];
        rightResult =
          if compressed then
            parseSide (elemAt sides 1)
          else
            {
              valid = true;
              segments = [ ];
            };
        rightSegments = rightResult.segments or [ ];
        segmentCount = (lib.length leftSegments) + (lib.length rightSegments);
        middleSegments = lib.genList (_: 0) (segmentFullCount - segmentCount);
        segments = leftSegments ++ middleSegments ++ rightSegments;
        valid =
          (lib.length sides == 1 || lib.length sides == 2)
          && leftResult.valid
          && rightResult.valid
          && !compressed
          ->
            segmentCount == segmentFullCount
            && segmentCount <= segmentFullCount
            && lib.all (s: s >= 0 && s <= this.segmentBitSize) segments;
      in
      { inherit valid; } // lib.optionalAttrs valid { segments = segments; };
    innerParseStrCore =
      addrStr:
      let
        ip4Regex = ''[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'';
        ip4ToIP6Fragment = ip4: [
          ((elemAt ip4 0) * 256 + (elemAt ip4 1))
          ((elemAt ip4 2) * 256 + (elemAt ip4 3))
        ];
        withoutBrackets = lib.pipe addrStr [
          (lib.removePrefix "[")
          (lib.removeSuffix "]")
        ];
        matches = builtins.match ''([0-9a-fA-F:]+)(:${ip4Regex})?(%[a-zA-Z0-9_-]+)?'' withoutBrackets;

        mainMatchBlegh = elemAt matches 0;
        ip4MatchBlegh = elemAt matches 1;
        zoneMatch = elemAt matches 2;

        hasIP4 = ip4MatchBlegh != null;
        ip4Match = lib.removePrefix ":" ip4MatchBlegh;
        mainMatch = if hasIP4 then mainMatchBlegh + ":" else mainMatchBlegh;
        ip4Parse = v4Data.innerParseStrCore ip4Match;
        ip4Segments = ip4Parse.mkArgs.segments;

        segmentsResult = parsePlain {
          str = mainMatch;
          bitsParsedSeparately = if hasIP4 then v4Data.bitSize else 0;
        };
        segments =
          if hasIP4 then segmentsResult.segments ++ ip4ToIP6Fragment ip4Segments else segmentsResult.segments;

        hasZone = zoneMatch != null;
        zone = if hasZone then lib.removePrefix "%" zoneMatch else null;

        valid =
          (lib.hasPrefix "[" addrStr) == (lib.hasSuffix "]" addrStr)
          && (matches != null)
          && ((lib.hasPrefix ":" mainMatch) -> (lib.hasPrefix "::" mainMatch))
          && ((lib.hasSuffix ":" mainMatch) -> ((lib.hasSuffix "::" mainMatch) || hasIP4))
          && (hasIP4 -> (lib.hasSuffix ":" mainMatch))
          && (hasIP4 -> ip4Parse.valid)
          && segmentsResult.valid;

        # debugData = { inherit mainMatch hasIP4 ip4Match; segmentValid = segmentsResult.valid; };
      in
      assert matches != null -> (builtins.length matches) == 3;
      # builtins.trace (builtins.deepSeq debugData debugData)
      { inherit valid; } // lib.optionalAttrs valid { mkArgs = { inherit segments zone; }; };
  });
  parseIPAny =
    str:
    let
      v4Result = v4Data.parseStrCore str;
      v6Result = v6Data.parseStrCore str;
    in
    lib.throwIf (v4Result.valid && v6Result.valid)
      "${lib.strings.escapeNixString str} is valid as both IPv4 and IPv6; This shouldn't happen"
      lib.throwIfNot
      (v4Result.valid || v6Result.valid)
      "${lib.strings.escapeNixString str} is not a valid IPv4 or IPv6 address"
      (if v4Result.valid then v4Data.mkIP v4Result.mkArgs else v6Data.mkIP v6Result.mkArgs);
  equalIPs =
    a: b:
    assert isIPAny a;
    assert isIPAny b;
    lib.all (attr: a.${attr} == b.${attr}) [
      "ipVersion"
      "segments"
      "hasPrefix"
      "prefixSize"
      "zone"
    ];
  methods = {
    inherit
      isIPAny
      parseIPAny
      v4Data
      v6Data
      equalIPs
      ;
    v4 = v4Data.publicMethods;
    v6 = v6Data.publicMethods;
  }
  //
    lib.pipe
      [ v4Data v6Data ]
      [
        (map (data: {
          "mkIP${toString data.versionInt}" = data.mkIP;
          "isIP${toString data.versionInt}" = data.isIP;
          "isValidIP${toString data.versionInt}Str" = data.isValidStr;
          "parseIP${toString data.versionInt}" = data.parse;
          "zeroIP${toString data.versionInt}" = data.zero;
        }))
        lib.mergeAttrsList
      ];
in
{
  ip = methods;
}
