# Security Policy

## Supported versions

| Version | Supported |
| ------- | --------- |
| 1.1.x   | ✅        |

## Reporting a vulnerability

Please **do not** open a public issue for security vulnerabilities.
Instead, open a [private security advisory](../../security/advisories/new) on this repo, or contact the maintainer through their GitHub profile. You'll get a response within a few days.

## Security design

This project is built around one principle: **your credentials never leave your machine.**

- The bridge binds to `127.0.0.1` only. It is not reachable from your LAN or the internet.
- Session tokens live in a local `.env` file, which is covered by `.gitignore` and never committed.
- No telemetry, no analytics, no outbound calls except the ones *you* trigger (your prompts → your Gemini session).
- The `.bat` launchers download installers **only** from official sources (`python.org`, `nodejs.org`, npm).

## Your responsibilities

- Never commit your real `.env` — use `.env.example` as the template.
- Never share screenshots containing tokens or API keys.
- If you expose the bridge beyond localhost (e.g. via a tunnel), you own that risk — use a firewall and strong auth.
