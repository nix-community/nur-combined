# Setup hook to check HA manifest requirements
echo "Sourcing manifest-requirements-check-hook"

function haManifestRequirementsCheckPhase() {
    echo "Executing haManifestRequirementsCheckPhase"
    runHook preCheck

    manifests=$(shopt -s nullglob; echo $out/custom_components/*/manifest.json)

    if [ ! -z "$manifests" ]; then
        echo Checking manifests $manifests
        @pythonCheckInterpreter@ @checkRequirements@ $manifests
    else
        echo "No custom component manifests found in $out" >&2
        exit 1
    fi

    runHook postCheck
    echo "Finished executing haManifestRequirementsCheckPhase"
}

if [ -z "${dontUseHaManifestRequirementsCheck-}" ] && [ -z "${installCheckPhase-}" ]; then
    echo "Using haManifestRequirementsCheckPhase"
    preDistPhases+=" haManifestRequirementsCheckPhase"
fi
