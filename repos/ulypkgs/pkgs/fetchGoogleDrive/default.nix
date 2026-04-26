{
  lib,
  stdenvNoCC,
  cacert,
  gdown,
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
        fileId ? null,
        folderId ? null,
        extraGdownArgs ? [ ],

        outputHash ? lib.fakeHash,
        outputHashAlgo ? null,
        preFetch ? "",
        postFetch ? "",
        nativeBuildInputs ? [ ],
        impureEnvVars ? [ ],
        passthru ? { },
        meta ? { },
        preferLocalBuild ? false,
        derivationArgs ? { },
      }:

      assert lib.assertMsg (
        fileId != null || folderId != null
      ) "Either fileId or folderId must be provided";
      assert lib.assertMsg (
        fileId == null || folderId == null
      ) "Only one of fileId or folderId can be provided";

      let
        finalHashHasColon = lib.hasInfix ":" finalAttrs.hash;
        finalHashColonMatch = lib.match "([^:]+)[:](.*)" finalAttrs.hash;
      in
      derivationArgs
      // {
        __structuredAttrs = true;

        name =
          if name != null then
            name
          else if fileId != null then
            fileId
          else
            folderId;

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
        outputHashMode = if folderId != null then "recursive" else "flat";

        nativeBuildInputs = [
          cacert
          gdown
        ]
        ++ nativeBuildInputs;

        inherit preferLocalBuild;

        inherit
          fileId
          folderId
          preFetch
          postFetch
          ;
        impureEnvVars =
          lib.fetchers.proxyImpureEnvVars
          ++ [
            "NIX_CONNECT_TIMEOUT"
            "NIX_GDOWN_COOKIES"
          ]
          ++ impureEnvVars;

        builder = ./builder.sh;
      }
    );

  inheritFunctionArgs = false;
}
