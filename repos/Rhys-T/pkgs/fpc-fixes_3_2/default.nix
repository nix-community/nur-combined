{ fpc, lib, fetchFromGitLab }: fpc.overrideAttrs (old: {
    version = "3.2.2-unstable-2025-08-01";
    src = fetchFromGitLab {
        owner = "freepascal.org";
        repo = "fpc/build";
        rev = "827229c5cbf207adf658f1aeefe761e8bfe39f89";
        fetchSubmodules = true;
        hash = "sha256-nEdX5JofAF8LFCzom9C25Ep+k9GcefwcaxcVcDzbCo4=";
    };
    patches = lib.pipe (old.patches or []) [
        (builtins.filter (patch: !(lib.hasInfix "a20a7e3497bccf3415bf47ccc55f133eb9d6d6a0" (""+patch)))) # upstreamed
        (map (patch: if lib.hasInfix "mark-paths" (""+patch) then ./mark-paths.patch else patch))
    ];
    meta = removeAttrs old.meta ["broken"] // {
        description = (old.meta.description or "FPC") + " (fixes_3_2 branch)";
    };
    passthru = removeAttrs (old.passthru or {}) ["updateScript"];
})
