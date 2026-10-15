{ lib, ... }:
let
  typeMatches =
    type:
    value:
    let
      eval = lib.evalModules {
        modules = [
          { options.testValue = lib.mkOption { inherit type; }; }
          { config.testValue = value; }
        ];
      };
    in
    lib.deepSeq eval.config.testValue true;
in
rec {
  _tests.typeMatchesMatchesTypes =
    let
      shouldFail = typeMatches lib.types.str 5;
    in
    !(builtins.tryEval shouldFail).success;

  types = {
    storeUrl = lib.types.str // {
      name = "vaculib.storeUrl";
      description = "nix store URL";
    };
    nixPublicKey = (lib.types.strMatching ''[^:]+:[a-zA-Z0-9+/]+={0,3}'') // {
      name = "vaculib.nixPublicKey";
      description = "nix public key";
    };
    _tests.nixPublicKey = typeMatches types.nixPublicKey "nixcache.shelvacu.com:73u5ZGBpPRoVZfgNJQKYYBt9K9Io/jPwgUfuOLsJbsM=";

    listOrSingle =
      elemType:
      lib.throwIf
        (elemType.check [ ])
        "vaculib.listOrSingle cannot be used with type ${elemType.name} because ${elemType.name} accepts a list"
        (lib.types.coercedTo elemType (x: [ x ]) (lib.types.listOf elemType)) // {
          name = "vaculib.listOrSingle";
          description = "list of, or a single ${
           lib.types.optionDescriptionPhrase (class: class == "noun" || class == "composite") elemType
          }";
        };
    _tests.listOrSingle = {
      element = typeMatches (types.listOrSingle lib.types.str) "hello";
      empty = typeMatches (types.listOrSingle lib.types.str) [ ];
      singleton = typeMatches (types.listOrSingle lib.types.str) [ "hi" ];
    };

    _tests.listOrSinglePublicKey = typeMatches (types.listOrSingle types.nixPublicKey) "nixcache.shelvacu.com:73u5ZGBpPRoVZfgNJQKYYBt9K9Io/jPwgUfuOLsJbsM=";
  };
}
