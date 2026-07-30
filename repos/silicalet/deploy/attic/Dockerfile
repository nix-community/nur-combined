FROM docker.xuanyuan.me/nixos/nix:2.34.8

# Keep attic-server reproducible with the nixpkgs revision pinned by the
# repository's flake.lock.
ARG NIXPKGS_REV=01fbdeef22b76df85ea168fbfe1bfd9e63681b30

RUN mkdir -p /opt /etc/attic /var/lib/atticd/storage \
    && nix --extra-experimental-features "nix-command flakes" \
      --option substituters "https://mirrors.cernet.edu.cn/nix-channels/store" \
      profile add --profile /opt/attic \
      "github:NixOS/nixpkgs/${NIXPKGS_REV}#attic-server" \
    && /opt/attic/bin/atticd --version \
    && chown -R 1000:1000 /var/lib/atticd

COPY server.toml /etc/attic/server.toml

ENV HOME="/var/lib/atticd"
ENV PATH="/opt/attic/bin:${PATH}"

VOLUME ["/var/lib/atticd"]
EXPOSE 8080

USER 1000:1000

ENTRYPOINT ["atticd"]
CMD ["--config", "/etc/attic/server.toml"]
