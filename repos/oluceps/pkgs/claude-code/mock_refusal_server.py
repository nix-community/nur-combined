#!/usr/bin/env python3
"""Mock Anthropic messages endpoint that always answers with a refusal.

Used to exercise Claude Code's `stop_reason: "refusal"` recovery path without
waiting for the real classifier to flag something. Serves one refusal turn
(tool_use + refusal) and then a normal end_turn for the retry, so the injected
meta note is written into the transcript and can be read back.
"""
from __future__ import annotations

import http.server
import json
import re
import sys

MODEL = "claude-sonnet-4-6"


def sse(events):
    out = []
    for name, payload in events:
        out.append(f"event: {name}\ndata: {json.dumps(payload)}\n\n")
    return "".join(out).encode()


class Handler(http.server.BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, fmt, *args):
        sys.stderr.write("[mock] " + (fmt % args) + "\n")

    def do_GET(self):
        self.send_response(200)
        self.send_header("content-type", "application/json")
        self.end_headers()
        self.wfile.write(b'{"models":[]}')

    def do_POST(self):
        n = int(self.headers.get("content-length", 0))
        body = self.rfile.read(n)
        req = json.loads(body or b"{}")
        messages = req.get("messages", [])
        # second request == the retry: answer cleanly.
        retried = any(
            "safety classifier" in json.dumps(m)
            or "cut off mid-stream" in json.dumps(m)
            for m in messages
        )
        sys.stderr.write(f"[mock] retried={retried} msgs={len(messages)}\n")

        if retried:
            events = [
                ("message_start", {"type": "message_start", "message": {
                    "id": "mock_ok", "type": "message", "role": "assistant",
                    "model": MODEL, "content": [], "stop_reason": None,
                    "usage": {"input_tokens": 10, "output_tokens": 10}}}),
                ("content_block_start", {"type": "content_block_start", "index": 0,
                    "content_block": {"type": "text", "text": ""}}),
                ("content_block_delta", {"type": "content_block_delta", "index": 0,
                    "delta": {"type": "text_delta", "text": "Done now."}}),
                ("content_block_stop", {"type": "content_block_stop", "index": 0}),
                ("message_delta", {"type": "message_delta",
                    "delta": {"stop_reason": "end_turn", "stop_sequence": None},
                    "usage": {"output_tokens": 4}}),
                ("message_stop", {"type": "message_stop"}),
            ]
        else:
            events = [
                ("message_start", {"type": "message_start", "message": {
                    "id": "mock_refused", "type": "message", "role": "assistant",
                    "model": MODEL, "content": [], "stop_reason": None,
                    "usage": {"input_tokens": 10, "output_tokens": 10}}}),
                ("content_block_start", {"type": "content_block_start", "index": 0,
                    "content_block": {"type": "text", "text": ""}}),
                ("content_block_delta", {"type": "content_block_delta", "index": 0,
                    "delta": {"type": "text_delta", "text": "Partial answer that gets cut."}}),
                ("content_block_stop", {"type": "content_block_stop", "index": 0}),
                ("content_block_start", {"type": "content_block_start", "index": 1,
                    "content_block": {"type": "tool_use", "id": "toolu_mock_1",
                        "name": "Bash", "input": {}}}),
                ("content_block_delta", {"type": "content_block_delta", "index": 1,
                    "delta": {"type": "input_json_delta", "partial_json": "{\"command\":\"echo hi\"}"}}),
                ("content_block_stop", {"type": "content_block_stop", "index": 1}),
                ("message_delta", {"type": "message_delta",
                    "delta": {"stop_reason": "refusal", "stop_sequence": None},
                    "usage": {"output_tokens": 8}}),
                ("message_stop", {"type": "message_stop"}),
            ]

        data = sse(events)
        self.send_response(200)
        self.send_header("content-type", "text/event-stream")
        self.send_header("content-length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_HEAD(self):
        self.send_response(200)
        self.end_headers()


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8765
    http.server.ThreadingHTTPServer(("127.0.0.1", port), Handler).serve_forever()
