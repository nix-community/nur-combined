package com.fzakaria.mvn2nix.maven;

import com.fzakaria.mvn2nix.maven.Artifact;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

public class ArtifactTest {

    @Test
    public void testEquals() {
        Artifact lhs = Artifact.fromCanonical("com.fzakaria:mvn2nix:jar:1");
        Artifact rhs = Artifact.fromCanonical("com.fzakaria:mvn2nix:jar:2");
        assertThat(lhs).isNotEqualTo(rhs);
        assertThat(lhs).isEqualTo(Artifact.fromCanonical("com.fzakaria:mvn2nix:jar:1"));
    }

    @Test
    public void testCanonical() {
        Artifact[][] actualAndExpectedValues = new Artifact[][]{
                new Artifact[]{
                        Artifact.fromCanonical("com.fzakaria:mvn2nix:jar:1"),
                        Artifact.builder()
                                .setGroup("com.fzakaria")
                                .setName("mvn2nix")
                                .setExtension("jar")
                                .setVersion("1")
                                .build()
                },
                new Artifact[]{
                        Artifact.fromCanonical("com.fzakaria:mvn2nix:jar:sources:1"),
                        Artifact.builder()
                                .setGroup("com.fzakaria")
                                .setName("mvn2nix")
                                .setExtension("jar")
                                .setClassifier("sources")
                                .setVersion("1")
                                .build()
                }
        };

        for (Artifact[] actualAndExpected : actualAndExpectedValues) {
            Artifact actual = actualAndExpected[0];
            Artifact expected = actualAndExpected[1];
            assertThat(actual).isEqualTo(expected);
        }
    }

}
