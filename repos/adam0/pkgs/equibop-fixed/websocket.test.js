import { expect, test } from "bun:test";
import WSServer from "./src/transports/websocket";
import detectable from "./detectable.json";

function connect() {
    const sent = [];
    const socket = {
        data: { clientId: detectable[0].id, encoding: "json" },
        send(data) {
            expect(this).toBe(socket);
            sent.push(data);
        }
    };
    const handlers = {
        connection(ws) {
            expect(ws).toBe(socket);
            ws.send(JSON.stringify({ evt: "READY" }));
        }
    };
    const server = Object.assign(Object.create(WSServer.prototype), { handlers });
    server.onConnection(socket);
    return { socket, sent };
}

test("connection sends READY without recursive send", () => {
    const { sent } = connect();
    expect(sent).toEqual(['{"evt":"READY"}']);
});

test("object messages are JSON-encoded exactly once", () => {
    const { socket, sent } = connect();
    const message = { cmd: "SET_ACTIVITY", nonce: "test", args: { activity: null } };
    // arRPC replaces the native string sender with an RPC object sender.
    socket.send(message);
    expect(sent[1]).toBe(JSON.stringify(message));
});

test("string messages are not double-encoded", () => {
    const { socket, sent } = connect();
    socket.send('{"cmd":"PING"}');
    expect(sent[1]).toBe('{"cmd":"PING"}');
});

test("repeated messages keep using the original socket sender", () => {
    const { socket, sent } = connect();
    for (let i = 0; i < 1000; i++) socket.send(String(i));
    expect(sent).toHaveLength(1001);
    expect(sent[1000]).toBe("999");
});
