use matchbox_socket::*;
fn test(mut s: WebRtcSocket) {
    let mut channel = s.channel(0);
    for (peer, packet) in channel.receive() {
        let _p: Box<[u8]> = packet;
    }
    channel.send(Box::new([1,2,3]), PeerId(uuid::Uuid::new_v4()));
}
