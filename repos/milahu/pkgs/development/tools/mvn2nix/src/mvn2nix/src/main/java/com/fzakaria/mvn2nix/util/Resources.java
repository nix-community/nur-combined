package com.fzakaria.mvn2nix.util;

import java.io.File;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.net.URL;
import java.nio.file.Files;

public final class Resources {

    private Resources() {
    }

    /**
     * Export a resource so that it can be used as a {@link File} object.
     * It is exported as a temporary file.
     */
    public static File export(String resourceName) {
        try {
            URL resource = com.google.common.io.Resources.getResource(resourceName);
            File tempResource = Files.createTempFile("exported", null).toFile();
            com.google.common.io.Resources.asByteSource(resource).copyTo(com.google.common.io.Files.asByteSink(tempResource));
            return tempResource;
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }
}
