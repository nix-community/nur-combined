package com.fzakaria.mvn2nix;

import com.fzakaria.mvn2nix.cmd.LoggingMixin;
import com.fzakaria.mvn2nix.cmd.Maven2nix;
import com.fzakaria.mvn2nix.cmd.PrintExceptionMessageHandler;
import picocli.CommandLine;

public class Main {

    static {
        // programmatic initialization; must be done before calling LogManager.getLogger()
        LoggingMixin.initializeLog4j();
    }

    public static void main(String[] args) {
        CommandLine cmd = new CommandLine(new Maven2nix())
                .setExecutionExceptionHandler(new PrintExceptionMessageHandler())
                .setExecutionStrategy(LoggingMixin::executionStrategy);
        int exitCode = cmd.execute(args);

        System.exit(exitCode);
    }
}
