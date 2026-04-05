{
  lib,
  stdenvNoCC,
  cacert,
  curl,
  pup,
}:

lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;
  excludeDrvArgNames = [
    "derivationArgs"
    "sha1"
    "sha256"
    "sha512"
  ];
  extendDrvArgs =
    finalAttrs:
    lib.fetchers.withNormalizedHash { } (
      {
        name ? null,
        url,

        outputHash ? lib.fakeHash,
        outputHashAlgo ? null,
        preFetch ? "",
        postFetch ? "",
        nativeBuildInputs ? [ ],
        impureEnvVars ? [ ],
        passthru ? { },
        meta ? { },
        preferLocalBuild ? true,
        derivationArgs ? { },
      }:
      let
        finalHashHasColon = lib.hasInfix ":" finalAttrs.hash;
        finalHashColonMatch = lib.match "([^:]+)[:](.*)" finalAttrs.hash;
      in
      derivationArgs
      // {
        __structuredAttrs = true;

        name = if name != null then name else "icon.png";

        hash =
          if outputHashAlgo == null || outputHash == "" || lib.hasPrefix outputHashAlgo outputHash then
            outputHash
          else
            "${outputHashAlgo}:${outputHash}";
        outputHash =
          if finalAttrs.hash == "" then
            lib.fakeHash
          else if finalHashHasColon then
            lib.elemAt finalHashColonMatch 1
          else
            finalAttrs.hash;
        outputHashAlgo = if finalHashHasColon then lib.head finalHashColonMatch else null;
        outputHashMode = "flat";

        nativeBuildInputs = [
          cacert
          curl
          pup
        ]
        ++ nativeBuildInputs;

        inherit preferLocalBuild;

        inherit
          url
          preFetch
          postFetch
          ;
        impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [ "NIX_CONNECT_TIMEOUT" ] ++ impureEnvVars;

        builder = ./builder.sh;
      }
    );

  inheritFunctionArgs = false;
}
