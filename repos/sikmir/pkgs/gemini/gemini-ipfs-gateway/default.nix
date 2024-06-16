{
  lib,
  buildGoModule,
  fetchFromSourcehut,
}:

buildGoModule {
  pname = "gemini-ipfs-gateway";
  version = "0-unstable-2023-10-19";

  src = fetchFromSourcehut {
    owner = "~hsanjuan";
    repo = "gemini-ipfs-gateway";
    rev = "f32f60780077627c552394cab92763779575e55c";
    hash = "sha256-44CLnlmfQQqw73Oy+GQ9525HZv+hx6IM/DrBgtEaaVg=";
  };

  vendorHash = "sha256-Y7Hm5QbUMz+T68wlTlx5zMjJIQXOe2zhYQZc41Dwjb8=";

  meta = {
    description = "IPFS access over the Gemini protocol";
    homepage = "https://git.sr.ht/~hsanjuan/gemini-ipfs-gateway";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
