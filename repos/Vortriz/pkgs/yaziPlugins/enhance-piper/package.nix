{
    inputs,
    timestampToDate,
    lib,
    mkYaziPlugin,
}:
mkYaziPlugin (finalAttrs: {
    pname = "enhance-piper.yazi";
    version = timestampToDate inputs._meta."enhance-piper.yazi".lastModified;

    src = inputs.${finalAttrs.pname};

    meta = {
        description = "A wrapper that caches Piper command outputs in RAM for better performance.";
        homepage = "https://github.com/boydaihungst/enhance-piper.yazi";
        license = lib.licenses.mit;
    };
})
