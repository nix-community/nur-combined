package com.fzakaria.mvn2nix.model;

import com.google.common.base.MoreObjects;

import javax.annotation.concurrent.Immutable;
import java.net.URL;
import java.util.Objects;

@Immutable
public class MavenArtifact {

    private final URL url;
    private final String layout;
    private final String sha256;

    public MavenArtifact(URL url, String layout, String sha256) {
        this.url = url;
        this.layout = layout;
        this.sha256 = sha256;
    }

    public URL getUrl() {
        return url;
    }

    public String getLayout() {
        return layout;
    }

    public String getSha256() {
        return sha256;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        MavenArtifact that = (MavenArtifact) o;
        return Objects.equals(url, that.url) &&
                Objects.equals(layout, that.layout) &&
                Objects.equals(sha256, that.sha256);
    }

    @Override
    public int hashCode() {
        return Objects.hash(url, layout, sha256);
    }

    @Override
    public String toString() {
        return MoreObjects.toStringHelper(this)
                .add("url", url)
                .add("layout", layout)
                .add("sha256", sha256)
                .toString();
    }
}
