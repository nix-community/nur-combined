{
    inputs,
    timestampToDate,
    lib,
    mkYaziPlugin,
}:
mkYaziPlugin (finalAttrs: {
    pname = "file-extra-metadata.yazi";
    version = timestampToDate inputs._meta."file-extra-metadata.yazi".lastModified;

    src = inputs.${finalAttrs.pname};

    meta = {
        description = "Replace the default file preview with extra information.";
        homepage = "https://github.com/boydaihungst/file-extra-metadata.yazi";
        license = lib.licenses.mit;
    };
})
