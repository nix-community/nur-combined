{
    inputs,
    date,
    lib,
    mkYaziPlugin,
}:
mkYaziPlugin (finalAttrs: {
    pname = "bunny.yazi";
    version = "unstable-${date}";

    src = inputs.${finalAttrs.pname};

    meta = {
        description = "Bookmarks menu for yazi with persistent and ephemeral bookmarks, fuzzy searching, previous directory, directory from another tab";
        homepage = "https://github.com/stelcodes/bunny.yazi";
        license = lib.licenses.mit;
    };
})
