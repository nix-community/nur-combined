## FTP provider
- async-curl
  - <https://github.com/LorenzoLeonardo/async-curl>
  - wrapper around `curl-rust` to make it `async` (specially for tokio)
- **curl-rust**
  - <https://github.com/alexcrichton/curl-rust>
  - 1-to-1 bindings to libcurl
  - no async; suggested to use curl "multi" API to achieve something similar
  - it's the only rust bindings mentioned by curl: <https://github.com/curl/everything-curl/blob/master/bindings/README.md>
- remotefs-fs-ftp
  - <https://github.com/remotefs-rs/remotefs-rs-ftp>
  - built on top of suppaftp; shares a dev
- rust_async_ftp
  - <https://github.com/dani-garcia/rust_async_ftp>
    - inactive since 2021
  - fork of rust-ftp, using the tokio `async` runtime
- suppaftp
  - <https://github.com/veeso/suppaftp>
  - kinda messy:
    - lots of code duplicated between the sync / async frontends
    - _partially_ generic, but not so generic as to allow a pluggable transport
  - sync or async
  - sync:
    - supports timeouts:
      - [x] `ImplFtpStream::connect_timeout` / `TcpStream::connect_timeout`
      - [ ] `ImplFtpStream::login` (no timeout)
      ...
    - general timeouts could be implemented via `std::net::TcpStream::set_read_timeout`
      - provide your own `TcpStream`: `ImplFtpStream::new_with_stream(s: TcpStream)`
      - in this case the timeout is applied per-read, so if bytes are coming in at a trickle it could still be unbounded in duration
    - general timeouts could be implemented by calling `TcpStream::shutdown`
      - but suppaftp wants to own the stream, so this might conflict with lifetimes/etc
  - async:
    - async_std backend (deprecated)
    - tokio backend


## FUSE provider
- fuser
  - <https://github.com/cberner/fuser>
  - rust-native port of the C `libfuse`
  - aims to support all features of libfuse 3.10.3
- fuse-backend-rs
  - <https://github.com/cloud-hypervisor/fuse-backend-rs>
  - "Rust FUSE library for server, virtio-fs and vhost-user-fs"
