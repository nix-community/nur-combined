package org.nixos.scsh3;

import java.io.File;

import opencard.core.util.OpenCardPropertyLoadingException;
import opencard.opt.util.OpenCardPropertyFileLoader;

/**
 * OpenCard configuration provider that behaves like the stock
 * OpenCardPropertyFileLoader, but falls back to the opencard.properties
 * shipped with the package (located via the scsh3.exepath system property)
 * for any key the user's configuration files do not define.
 *
 * OCF merges configuration key by key, first definition wins, so loading
 * the packaged defaults last gives them the lowest precedence. Upstream
 * achieves the same effect by running from its installation directory,
 * which places the bundled opencard.properties at the end of the search
 * path (as ./opencard.properties); a Nix wrapper must not change the
 * working directory, hence this loader.
 */
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
