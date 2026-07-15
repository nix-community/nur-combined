package org.nixos.scsh3;

import java.io.File;

import opencard.core.util.OpenCardPropertyLoadingException;
import opencard.opt.util.OpenCardPropertyFileLoader;

public class DefaultConfigurationLoader extends OpenCardPropertyFileLoader {

    @Override
    public void loadProperties() throws OpenCardPropertyLoadingException {
        try {
            super.loadProperties();
        } catch (OpenCardPropertyLoadingException e) {
            // No user configuration found; the packaged defaults suffice.
        }

        String exepath = System.getProperty("scsh3.exepath");
        if (exepath != null) {
            load(exepath + File.separator + "opencard.properties");
        }
    }
}
