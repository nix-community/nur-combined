package ir.amirab.util.startup;

import java.util.Collections;
import java.util.List;

/**
 * Disables AB Download Manager's built-in autostart writer in the Nix package.
 *
 * <p>This class intentionally has the same fully qualified name and public API
 * as ABDM's upstream {@code Startup} class. The package puts the JAR containing
 * this class before the upstream auto-start JAR on the application classpath,
 * so ABDM receives a no-op startup manager and cannot create, overwrite, or
 * remove the XDG autostart entry managed declaratively by Home Manager.</p>
 */
public final class Startup {
    public static final Startup INSTANCE = new Startup();

    private Startup() {
    }

    public AbstractDesktopStartupManager getStartUpManagerForDesktop(
            String name,
            String path,
            List<String> args,
            String packageName) {
        return new HeadlessStartupDesktop("", "", Collections.emptyList());
    }
}
