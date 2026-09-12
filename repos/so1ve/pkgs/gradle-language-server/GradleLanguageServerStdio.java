import com.microsoft.gradle.GradleLanguageServer;
import org.eclipse.lsp4j.jsonrpc.Launcher;
import org.eclipse.lsp4j.services.LanguageClient;

public final class GradleLanguageServerStdio {
    public static void main(String[] args) throws Exception {
        var server = new GradleLanguageServer();
        var launcher = Launcher.createLauncher(server, LanguageClient.class, System.in, System.out);
        server.connect(launcher.getRemoteProxy());
        launcher.startListening().get();
    }
}
