{ fpc, lib, fetchFromGitLab }: fpc.overrideAttrs (old: {
    version = "3.2.2-unstable-2025-08-01";
    src = fetchFromGitLab {
        owner = "freepascal.org";
        repo = "fpc/build";
        rev = "827229c5cbf207adf658f1aeefe761e8bfe39f89";
        fetchSubmodules = true;
        hash = "sha256-nEdX5JofAF8LFCzom9C25Ep+k9GcefwcaxcVcDzbCo4=";
    };
    patches = map (p: if lib.hasInfix "mark-paths" (""+p) then ./mark-paths.patch else p) (old.patches or []);
    meta = removeAttrs old.meta ["broken"] // {
        description = (old.meta.description or "FPC") + " (fixes_3_2 branch)";
    };
    passthru = removeAttrs (old.passthru or {}) ["updateScript"];
})
