package com.fzakaria.mvn2nix.cmd;

import com.fzakaria.mvn2nix.util.Resources;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import picocli.CommandLine;

import java.io.File;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;

import static org.assertj.core.api.Assertions.assertThat;

public class Maven2NixIT {

    @BeforeAll
    public static void beforeAll() {
        assertThat(System.getenv("M2_HOME"))
                .withFailMessage("M2_HOME must be present in order to run the integration tests.\n" +
                "Please make sure you are either running from nix-shell, direnv or that your IDE (i.e. IntelliJ) has been started from the shell.")
                .isNotBlank();
    }

    @Test
    public void simpleTest() throws Exception {
        Maven2nix app = new Maven2nix();
        CommandLine cmd = new CommandLine(app);
        StringWriter sw = new StringWriter();
        cmd.setOut(new PrintWriter(sw));

        File pom = Resources.export("samples/basic/pom.xml");
        cmd.execute(pom.getPath());

        String expected = com.google.common.io.Resources.toString(
                com.google.common.io.Resources.getResource("samples/basic/mvn2nix-lock.json"),
                StandardCharsets.UTF_8);
        String actual = sw.getBuffer().toString();
        assertThat(actual).isEqualToIgnoringNewLines(expected);
    }
}
