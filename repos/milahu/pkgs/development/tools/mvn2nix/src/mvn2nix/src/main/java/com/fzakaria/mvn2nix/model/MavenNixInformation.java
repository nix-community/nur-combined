package com.fzakaria.mvn2nix.model;

import com.google.common.base.MoreObjects;

import javax.annotation.concurrent.Immutable;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.TreeMap;

@Immutable
public class MavenNixInformation {

    private final Map<String, MavenArtifact> dependencies;

    /**
     * Stores the given dependencies in a tree map to get the artifacts in alphabetic order when this
     * object is converted to json by {@link com.fzakaria.mvn2nix.cmd.Maven2nix#toPrettyJson}.
     */
    public MavenNixInformation(Map<String, MavenArtifact> dependencies) {
        this.dependencies = new TreeMap<>(dependencies);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        MavenNixInformation that = (MavenNixInformation) o;
        return Objects.equals(dependencies, that.dependencies);
    }

    @Override
    public int hashCode() {
        return Objects.hash(dependencies);
    }

    @Override
    public String toString() {
        return MoreObjects.toStringHelper(this)
                .add("dependencies", dependencies)
                .toString();
    }
}
