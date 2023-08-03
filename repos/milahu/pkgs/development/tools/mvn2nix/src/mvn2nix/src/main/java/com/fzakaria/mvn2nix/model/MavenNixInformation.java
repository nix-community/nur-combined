package com.fzakaria.mvn2nix.model;

import com.google.common.base.MoreObjects;

import javax.annotation.concurrent.Immutable;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

@Immutable
public class MavenNixInformation {

    private final Map<String, MavenArtifact> dependencies;

    public MavenNixInformation(Map<String, MavenArtifact> dependencies) {
        this.dependencies = new HashMap<>(dependencies);
    }

    public Map<String, MavenArtifact> getDependencies() {
        return new HashMap<>(dependencies);
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
