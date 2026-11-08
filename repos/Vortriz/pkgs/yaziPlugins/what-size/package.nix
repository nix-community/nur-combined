{
    inputs,
    date,
    lib,
    mkYaziPlugin,
}:
mkYaziPlugin (finalAttrs: {
    pname = "what-size.yazi";
    version = "unstable-${date}";

    src = inputs.${finalAttrs.pname};

    meta = {
        description = "A plugin for yazi to calculate the size of current selection or current working directory";
        homepage = "https://github.com/pirafrank/what-size.yazi";
        license = lib.licenses.mit;
    };
})
