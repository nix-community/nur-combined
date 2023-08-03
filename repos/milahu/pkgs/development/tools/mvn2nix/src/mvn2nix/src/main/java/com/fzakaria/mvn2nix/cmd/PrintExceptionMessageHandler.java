package com.fzakaria.mvn2nix.cmd;

import picocli.CommandLine;
import picocli.CommandLine.ParseResult;

import static picocli.CommandLine.IExecutionExceptionHandler;

/**
 * Prints a friendly message to STDERR and only includes the stack trace if verbose is on
 */
public class PrintExceptionMessageHandler implements IExecutionExceptionHandler {
    public int handleExecutionException(Exception ex,
                                        CommandLine cmd,
                                        ParseResult parseResult) {

        // bold red error message
        String message = ex.getMessage() != null ? ex.getMessage() : ex.getClass().getName();

        cmd.getErr().println(cmd.getColorScheme().errorText(message));

        if (((Maven2nix) (cmd.getCommandSpec().userObject())).loggingMixin.isVerboseEnabled()) {
            ex.printStackTrace();
        }

        return cmd.getExitCodeExceptionMapper() != null
                ? cmd.getExitCodeExceptionMapper().getExitCode(ex)
                : cmd.getCommandSpec().exitCodeOnExecutionException();
    }
}