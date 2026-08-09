#!/usr/bin/env python3
"""
LobbyLoop server.

Serves the index page, the poster GIF files, and a small API.
Run with: python3 server.py
Then open http://localhost:8080 in a browser (or point Chromium kiosk mode at it).
"""

import http.server
import json
import os
import socketserver

PORT = 8080
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
POSTER_DIR = os.path.join(BASE_DIR, "posters")


class LobbyLoopHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=BASE_DIR, **kwargs)

    def do_GET(self):
        if self.path == "/api/posters":
            self.handle_poster_list()
        elif self.path == "/api/now-playing":
            self.handle_now_playing()
        else:
            super().do_GET()

    def handle_poster_list(self):
        try:
            files = [
                f for f in os.listdir(POSTER_DIR)
                if f.lower().endswith(".gif")
            ]
            files.sort()
        except FileNotFoundError:
            files = []

        body = json.dumps(files).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def handle_now_playing(self):
        # Placeholder for the future Jellyfin integration.
        # For now this always reports nothing playing, so the page
        # just keeps cycling through the poster folder.
        #
        # Later, replace this with a real call to the Jellyfin API,
        # and return something like:
        # {"title": "Movie Name", "posterFile": "posters/movie.gif"}
        body = json.dumps({"title": None, "posterFile": None}).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


def main():
    os.makedirs(POSTER_DIR, exist_ok=True)
    with socketserver.TCPServer(("0.0.0.0", PORT), LobbyLoopHandler) as httpd:
        print(f"LobbyLoop server running on port {PORT}")
        httpd.serve_forever()


if __name__ == "__main__":
    main()
