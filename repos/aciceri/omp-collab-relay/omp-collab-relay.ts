/**
 * Self-hosted omp collab relay, vendored from oh-my-pi's
 * `packages/collab-web/scripts/local-relay.ts` with the envelope helpers
 * inlined. Payloads stay sealed end to end (AES-256-GCM on the clients);
 * TLS and access control live in nginx above us, so we bind loopback only.
 */
const ROOM_PATH_RE = /^\/r\/([A-Za-z0-9_-]{10,64})$/;
const ENVELOPE_HEADER_LENGTH = 4;

const PORT = Number(process.env.OMP_COLLAB_RELAY_PORT ?? "7475");

interface SocketData {
	roomId: string;
	role: "host" | "guest";
	/** Assigned on open for guests; the host stays 0. */
	peerId: number;
}

type RelaySocket = Bun.ServerWebSocket<SocketData>;

interface Room {
	host: RelaySocket;
	guests: Map<number, RelaySocket>;
	nextPeerId: number;
}

function envelopePeerId(data: Uint8Array): number | null {
	if (data.byteLength < ENVELOPE_HEADER_LENGTH) return null;
	return new DataView(data.buffer, data.byteOffset, ENVELOPE_HEADER_LENGTH).getUint32(0, false);
}

/** Rewrite the peerId in place without copying the payload. */
function rewriteEnvelopePeer(data: Uint8Array, peerId: number): void {
	new DataView(data.buffer, data.byteOffset, ENVELOPE_HEADER_LENGTH).setUint32(0, peerId, false);
}

const rooms = new Map<string, Room>();

const server = Bun.serve({
	hostname: "127.0.0.1",
	port: PORT,
	fetch(req, srv): Response | undefined {
		const url = new URL(req.url);
		if (url.pathname === "/healthz") return new Response("ok");
		const match = ROOM_PATH_RE.exec(url.pathname);
		const role = url.searchParams.get("role");
		if (!match || (role !== "host" && role !== "guest")) {
			return new Response("not found", { status: 404 });
		}
		const data: SocketData = { roomId: match[1]!, role, peerId: 0 };
		if (srv.upgrade(req, { data })) return undefined;
		return new Response("websocket upgrade required", { status: 426 });
	},
	websocket: {
		open(ws: RelaySocket): void {
			const { roomId, role } = ws.data;
			if (role === "host") {
				if (rooms.has(roomId)) {
					ws.close(4009, "a host is already connected for this room");
					return;
				}
				rooms.set(roomId, { host: ws, guests: new Map(), nextPeerId: 1 });
				return;
			}
			const room = rooms.get(roomId);
			if (!room) {
				ws.close(4004, "no such room");
				return;
			}
			const peerId = room.nextPeerId++;
			ws.data.peerId = peerId;
			room.guests.set(peerId, ws);
			room.host.send(JSON.stringify({ t: "peer-joined", peer: peerId }));
		},
		message(ws: RelaySocket, message: string | Buffer): void {
			if (typeof message === "string") return; // clients never send TEXT
			const room = rooms.get(ws.data.roomId);
			if (!room) return;
			if (ws.data.role === "host") {
				const peerId = envelopePeerId(message);
				if (peerId === null) return;
				if (peerId === 0) {
					for (const guest of room.guests.values()) guest.send(message);
				} else {
					room.guests.get(peerId)?.send(message);
				}
				return;
			}
			if (message.byteLength < ENVELOPE_HEADER_LENGTH) return;
			rewriteEnvelopePeer(message, ws.data.peerId);
			room.host.send(message);
		},
		close(ws: RelaySocket): void {
			const { roomId, role, peerId } = ws.data;
			const room = rooms.get(roomId);
			if (!room) return;
			if (role === "host") {
				// Rejected second host: the live room is not ours to tear down.
				if (room.host !== ws) return;
				rooms.delete(roomId);
				const closure = JSON.stringify({ t: "room-closed" });
				for (const guest of room.guests.values()) {
					guest.send(closure);
					guest.close(4001, "room closed");
				}
				room.guests.clear();
				return;
			}
			if (room.guests.delete(peerId)) {
				room.host.send(JSON.stringify({ t: "peer-left", peer: peerId }));
			}
		},
	},
});

console.log(`omp collab relay listening on ws://127.0.0.1:${server.port}`);
