# AGENTS.md

Instructions and conventions for working on this project.

## Project summary

LobbyLoop displays animated GIF movie posters fullscreen on a Raspberry Pi,
cycling through a folder of GIF files on a loop. It is meant to run as a
kiosk display. A later phase adds Jellyfin integration, so the display
shows the poster for whatever is currently playing on Jellyfin instead of
looping, when something is playing.

## Language and writing conventions

Apply these rules to all code comments, documentation, commit messages, and
any text generated for this project:

- Never use em dashes. Use commas, colons, semicolons, or separate
  sentences instead.
- Never use the Unicode ellipsis character. Write out "and so on" or use
  three separate periods if needed, but prefer avoiding it entirely.
- Use plain, literal language. Say things directly.
- No idioms or figures of speech.
- Keep documentation concise and structured. Prefer short paragraphs and
  bullet lists over long prose blocks.

## Code conventions

- Python is the primary language for the server, since it comes
  preinstalled on Raspberry Pi OS and needs no extra setup.
- Keep the server dependency-free where possible. Use the standard library
  (`http.server`, `urllib`, `json`) instead of adding packages, unless a
  package clearly saves significant complexity.
- Frontend code is plain HTML, CSS, and JavaScript. No build step, no
  frameworks, no bundler.
- If a JavaScript test runner is ever needed for this project, use Node's
  built in test runner rather than adding a testing framework.

## File structure

- `index.html`: the display page, including poster cycling, video and GIF
  playback, and the Jellyfin polling stub.
- `server.py`: serves the page and the small JSON API (`/api/posters`,
  `/api/now-playing`). Lists both GIF and video poster files.
- `posters/`: local poster files to loop through. Supports GIF, mp4,
  webm, JPG, PNG, and WebP.
- `convert-posters.sh`: batch converts GIF posters to mp4, for better
  playback performance on a Raspberry Pi.
- `kiosk.sh`: launches Chromium in fullscreen kiosk mode.
- `lobbyloop-server.service`, `lobbyloop-kiosk.service`: systemd units for
  running the server and kiosk browser on boot.
- `README.md`: setup and usage instructions for a human reader.
- `CLAUDE.md`: points here.

## Notes for future work

- The Jellyfin integration should call the Jellyfin API directly using an
  API key, no separate library is needed.
- If Home Assistant or Roku integration is added later, keep it isolated
  to its own function or module so it can be swapped out or removed
  without touching the core poster loop logic.
