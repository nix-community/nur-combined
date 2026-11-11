{
    inputs,
    timestampToDate,
    lib,
    mkYaziPlugin,
}:
mkYaziPlugin (finalAttrs: {
    pname = "custom-shell.yazi";
    version = timestampToDate inputs._meta."custom-shell.yazi".lastModified;

    src = inputs.${finalAttrs.pname};

    meta = {
        description = "Set your custom-shell as default shell in yazi";
        homepage = "https://github.com/AnirudhG07/custom-shell.yazi";
        license = lib.licenses.mit;
    };
})
