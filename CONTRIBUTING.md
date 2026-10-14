# Contributing

Thanks for wanting to make this better! A few ground rules:

## How to contribute

1. **Fork** the repo and create a branch from `main` (`git checkout -b feat/my-thing`).
2. Make your change. Keep it focused — one PR, one idea.
3. **Test it**: run the bridge (`uvicorn main:app --host 127.0.0.1 --port 5000`) and hit at least `/health` and `/v1/models`. If you touched a `.bat` launcher, test it on a real Windows machine.
4. Open a **pull request** describing what changed and why. Screenshots for anything visual.

## What we're looking for

- 🐧 **macOS / Linux launchers** — `.sh` equivalents of the `.bat` files (most requested!)
- 🧪 Tests for the bridge endpoints
- 📚 Better docs, translations, troubleshooting guides
- 🐛 Bug reports with reproduction steps (OS, Python/Node versions, logs)

## What we won't merge

- Anything that phones home, adds telemetry, or exfiltrates credentials
- Changes that bind the bridge to `0.0.0.0` or expose it beyond localhost by default
- Committed secrets (`.env`, tokens, API keys) — these are rejected on sight

## Code style

- Python: readable over clever. Type hints where they help.
- Keep the bridge dependency-light — every new dependency is a new install failure mode on someone's laptop.

By contributing, you agree your contributions are licensed under the MIT License.
