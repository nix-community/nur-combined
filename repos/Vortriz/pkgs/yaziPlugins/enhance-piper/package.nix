{
    inputs,
    date,
    lib,
    mkYaziPlugin,
}:
mkYaziPlugin (finalAttrs: {
    pname = "enhance-piper.yazi";
    version = "unstable-${date}";

    src = inputs.${finalAttrs.pname};

    meta = {
        description = "A wrapper that caches Piper command outputs in RAM for better performance.";
        homepage = "https://github.com/boydaihungst/enhance-piper.yazi";
        license = lib.licenses.mit;
    };
})
