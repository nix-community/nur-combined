{
  lib,
  gradle2nix,
  androidenv,
  jdk_headless,
  writeScriptBin,
  gradle,
  makeVacuPythonScript,
  bashNonInteractive,
  vacuRoot,
  vacuWrappedSops,
}:
{
  jdk ? jdk_headless,
  gradleBuildTask ? ":${subprojectName}:assembleRelease",
  gradleDependenciesTask ? "resolveAllArtifacts",
  lockFile ? null,
  extraLockData ? null,
  extraComposeArgs ? { },
  subprojectName ? "app",
  sdkVersions ? [ "37" ],
  # also:
  # applicationId,
  # applicationIds,
  ...
}@args:
let
  otherArgs = builtins.removeAttrs args [
    "jdk"
    "gradleBuildTask"
    "gradleDependenciesTask"
    "lockFile"
    "extraLockData"
    "extraComposeArgs"
    "subprojectName"

    "applicationId"
    "applicationIds"
  ];
  hasApplicationId = args ? applicationId;
  hasApplicationIds = args ? applicationIds;
  errors = [
    {
      condition = (!hasApplicationId) && (!hasApplicationIds);
      message = "Must pass applicationId xor applicationIds";
    }
    {
      condition = hasApplicationId && hasApplicationIds;
      message = "Cannot pass both applicationId and applicationIds";
    }
    {
      condition = args ? installPhase;
      message = "Cannot pass installPhase";
    }
  ];
  withErrors =
    x:
    let
      applicableErrors = lib.pipe errors [
        (builtins.filter (x: x.condition))
        (map (x: "buildGradleAndroidPackage: ${x.message}"))
      ];
    in
    lib.throwIf (applicableErrors != [ ]) (builtins.head applicableErrors) x;
  applicationIds = if args.applicationId == null then args.applicationIds else args.applicationId;
  anyName = args.pname or args.name;
  originalLockData = builtins.fromJSON (builtins.readFile lockFile);
  withExtraLockData =
    originalLockData
    // extraLockData
    // (builtins.mapAttrs (
      name: _:
      let
        original = originalLockData.${name};
        extra = extraLockData.${name};
        intersect = builtins.intersectAttrs original extra;
      in
      lib.throwIf (intersect != { })
        "conflict in buildGradleAndroidPackage for ${anyName}: both ${lockFile} and extraLockData have ${lib.strings.escapeNixString name}.{${
          lib.mapConcatStringsSep "," lib.strings.escapeNixString (builtins.attrNames intersect)
        }}"
        (original // extra)
    ) (builtins.intersectAttrs originalLockData extraLockData));
  withExtraLockFile = builtins.toFile "gradle-with-extraLockData.lock" (
    builtins.toJSON withExtraLockData
  );

  androidPkgs = androidenv.composeAndroidPackages (
    {
      platformVersions = sdkVersions;
      buildToolsVersions = map (x: "${x}.0.0") sdkVersions;
      includeNDK = true;
    }
    // extraComposeArgs
  );
  env = rec {
    JAVA_HOME = jdk.home;
    ANDROID_HOME = "${androidPkgs.androidsdk}/libexec/android-sdk";
    ANDROID_SDK_ROOT = ANDROID_HOME;
  };
in
gradle2nix.buildGradlePackage (
  otherArgs
  // {
    env = env // (args.env or { });
    nativeBuildInputs = [
      ./setup-hook.sh
      androidPkgs.androidsdk
      jdk
    ]
    ++ (args.nativeBuildInputs or [ ]);

    lockFile = if lockFile != null && extraLockData != null then withExtraLockFile else lockFile;

    gradle = (args.gradle or gradle);

    gradleBuildFlags = [
      "--no-daemon"
      gradleBuildTask
    ]
    ++ (args.gradleBuildFlags or [ ]);

    installPhase = withErrors ''
      runHook preInstall

      mkdir $out
      cp -r ${subprojectName}/build/outputs/* $out

      # remove impurities
      rm -r $out/logs
      (
        shopt -s globstar nullglob
        # these are zip files, the only impurity is the modified timestamp. Ideally we'd just fix that
        rm $out/apk/**/baselineProfiles/?/*.dm || true
        if [[ -d $out/mapping ]]; then
          declare -a configurationTxtFiles=($out/mapping/*/configuration.txt)
          if (( ''${#configurationTxtFiles[@]} > 0 )); then
            substituteInPlace "''${configurationTxtFiles[@]}" \
              --replace-warn "$GRADLE_USER_HOME" /build/gradle-user-home
          fi
          for seedsFile in $out/mapping/*/seeds.txt; do
            sort "$seedsFile" -o "$seedsFile"
          done
        fi
      )

      runHook postInstall
    '';

    passthru = (args.passthru or { }) // {
      inherit androidPkgs applicationIds;
      gradle2nix = writeScriptBin "gradle2nix-for-${anyName}" ''
        #!${lib.getExe bashNonInteractive}
        ${lib.toShellVars env}
        export JAVA_HOME
        export ANDROID_HOME
        if [[ -z ''${GITHUB_TOKEN:-} ]]; then
          if GITHUB_TOKEN="$(${lib.getExe vacuWrappedSops} decrypt --extract '["token"]' ${/${vacuRoot}/secrets/misc/github-pat-for-repos.yaml})"; then
            export GITHUB_TOKEN
          else
            echo "warn: failed to call sops" >&2
          fi
        fi
        exec ${lib.getExe gradle2nix} --task=${gradleDependenciesTask} --gradle-jdk=${jdk.home} --gradle-home=${args.gradle or gradle}/libexec/gradle "$@"
      '';
      addMavenFiles = makeVacuPythonScript {
        name = "addMavenFiles-buildGradlePackage-for-${anyName}";
        makeWrapperArgs = lib.pipe env [
          lib.attrsToList
          (map (
            { name, value }: [
              "--set"
              name
              value
            ]
          ))
          lib.flatten
        ];
        src = ./addMavenFiles.py;
      };
    };
  }
)
