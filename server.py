#!/usr/bin/env python3
"""Beach Terminal server — serves UI + sends commands to tmux sessions."""
import http.server
import json
import subprocess
import urllib.parse
import os

PORT = 7681
DIR = os.path.dirname(os.path.abspath(__file__))
SESSIONS = ["claude", "dev", "git", "misc", "term5", "term6", "term7", "term8"]


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIR, **kwargs)

    def _env(self):
        return {"PATH": os.environ.get("PATH", "/usr/bin:/bin:/opt/homebrew/bin"),
                "HOME": os.environ.get("HOME", "")}

    def _ok(self, data=b'{"ok":true}'):
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(data)

    def _err(self, e):
        self.send_response(500)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps({"error": str(e)}).encode())

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = json.loads(self.rfile.read(length)) if length else {}

        if self.path == "/send":
            session = body.get("session", "claude")
            text = body.get("text", "")
            ctrl_c = body.get("ctrl_c", False)
            no_enter = body.get("no_enter", False)
            try:
                if ctrl_c:
                    subprocess.run(["tmux", "send-keys", "-t", session, "C-c"],
                                   timeout=5, env=self._env())
                elif no_enter:
                    # Send raw keys without Enter (for Claude Code option selection)
                    subprocess.run(["tmux", "send-keys", "-t", session, text],
                                   timeout=5, env=self._env())
                else:
                    subprocess.run(["tmux", "send-keys", "-t", session, text, "Enter"],
                                   timeout=5, env=self._env())
                self._ok()
            except Exception as e:
                self._err(e)

        elif self.path == "/restart":
            session = body.get("session", "claude")
            launcher = os.path.expanduser("~/beach-terminal/launcher.sh")
            try:
                # Kill everything in the pane, then start a fresh shell with launcher
                subprocess.run(["tmux", "send-keys", "-t", session, "C-c"], timeout=5, env=self._env())
                subprocess.run(["tmux", "send-keys", "-t", session, "exit", "Enter"], timeout=5, env=self._env())
                # Small delay then respawn
                subprocess.run(["tmux", "respawn-pane", "-k", "-t", session, launcher],
                               timeout=5, env=self._env())
                self._ok()
            except Exception as e:
                self._err(e)

        else:
            self.send_response(404)
            self.end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def log_message(self, format, *args):
        pass  # silent


if __name__ == "__main__":
    server = http.server.HTTPServer(("0.0.0.0", PORT), Handler)
    print(f"Beach Terminal server on port {PORT}")
    server.serve_forever()
