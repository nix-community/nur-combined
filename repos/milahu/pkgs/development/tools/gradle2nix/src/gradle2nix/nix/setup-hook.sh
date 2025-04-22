# shellcheck shell=bash disable=SC2206,SC2155

gradleConfigurePhase() {
    runHook preConfigure

    if ! [[ -v enableParallelBuilding ]]; then
        enableParallelBuilding=1
        echo "gradle: enabled parallel building"
    fi

    if ! [[ -v enableParallelChecking ]]; then
        enableParallelChecking=1
        echo "gradle: enabled parallel checking"
    fi

    if ! [[ -v enableParallelInstalling ]]; then
        enableParallelInstalling=1
        echo "gradle: enabled parallel installing"
    fi

    export GRADLE_USER_HOME="$(mktemp -d)"

    if [ -n "$gradleInitScript" ]; then
        if [ ! -f "$gradleInitScript" ]; then
            echo "gradleInitScript is not a file path: $gradleInitScript"
            exit 1
        fi
        mkdir -p "$GRADLE_USER_HOME/init.d"
        ln -s "$gradleInitScript" "$GRADLE_USER_HOME/init.d"
    fi

    runHook postConfigure
}

gradleBuildPhase() {
    runHook preBuild

    if [ -z "${gradleBuildFlags:-}" ] && [ -z "${gradleBuildFlagsArray[*]}" ]; then
        echo "gradleBuildFlags is not set, doing nothing"
    else
        local flagsArray=(
            $gradleFlags "${gradleFlagsArray[@]}"
            $gradleBuildFlags "${gradleBuildFlagsArray[@]}"
        )

        if [ -n "$enableParallelBuilding" ]; then
            flagsArray+=(--parallel --max-workers ${NIX_BUILD_CORES})
        else
            flagsArray+=(--no-parallel)
        fi

        echoCmd 'gradleBuildPhase flags' "${flagsArray[@]}"

        gradle "${flagsArray[@]}"
    fi

    runHook postBuild
}

gradleCheckPhase() {
    runHook preCheck

    if [ -z "${gradleCheckFlags:-}" ] && [ -z "${gradleCheckFlagsArray[*]}" ]; then
        echo "gradleCheckFlags is not set, doing nothing"
    else
        local flagsArray=(
            $gradleFlags "${gradleFlagsArray[@]}"
            $gradleCheckFlags "${gradleCheckFlagsArray[@]}"
            ${gradleCheckTasks:-check}
        )

        if [ -n "$enableParallelChecking" ]; then
            flagsArray+=(--parallel --max-workers ${NIX_BUILD_CORES})
        else
            flagsArray+=(--no-parallel)
        fi

        echoCmd 'gradleCheckPhase flags' "${flagsArray[@]}"

        gradle "${flagsArray[@]}"
    fi

    runHook postCheck
}

gradleInstallPhase() {
    runHook preInstall

    if [ -z "${gradleInstallFlags:-}" ] && [ -z "${gradleInstallFlagsArray[*]}" ]; then
        echo "gradleInstallFlags is not set, doing nothing"
    else
        local flagsArray=(
            $gradleFlags "${gradleFlagsArray[@]}"
            $gradleInstallFlags "${gradleInstallFlagsArray[@]}"
        )

        if [ -n "$enableParallelInstalling" ]; then
            flagsArray+=(--parallel --max-workers ${NIX_BUILD_CORES})
        else
            flagsArray+=(--no-parallel)
        fi

        echoCmd 'gradleInstallPhase flags' "${flagsArray[@]}"

        gradle "${flagsArray[@]}"
    fi

    runHook postInstall
}

if [ -z "${dontUseGradleConfigure-}" ] && [ -z "${configurePhase-}" ]; then
    configurePhase=gradleConfigurePhase
fi

if [ -z "${dontUseGradleBuild-}" ] && [ -z "${buildPhase-}" ]; then
    buildPhase=gradleBuildPhase
fi

if [ -z "${dontUseGradleCheck-}" ] && [ -z "${checkPhase-}" ]; then
    checkPhase=gradleCheckPhase
fi

if [ -z "${dontUseGradleInstall-}" ] && [ -z "${installPhase-}" ]; then
    installPhase=gradleInstallPhase
fi
