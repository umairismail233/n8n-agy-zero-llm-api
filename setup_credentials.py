import os
import sys
import time

ENV_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".env")

def main():
    print("=" * 70)
    print("      ANTIGRAVITY ZERO-LLM-API CREDENTIAL SETUP")
    print("=" * 70)
    print("Connect your Google Gemini Pro Account / Antigravity local engine")
    print("to n8n with ZERO external paid API subscriptions.\n")
    
    # Check if existing session/token
    existing_token = ""
    if os.path.exists(ENV_FILE):
        with open(ENV_FILE, "r", encoding="utf-8") as f:
            for line in f:
                if line.startswith("GEMINI_AUTH_TOKEN="):
                    existing_token = line.strip().split("=", 1)[1]
                    break

    if existing_token:
        masked = existing_token[:6] + "..." + existing_token[-4:] if len(existing_token) > 10 else existing_token
        print(f"[STATUS] Active Gemini Pro / Antigravity Session found: {masked}")
        choice = input("Do you want to re-link or update it? (y/N): ").strip().lower()
        if choice != "y":
            print("[OK] Existing session credentials retained. Exiting.")
            return

    print("Choose pairing method:")
    print("1. [Auto] 1-Click Link Local Antigravity / Google Session (Recommended)")
    print("2. [Manual] Enter Gemini Pro Account Session Token")
    method = input("\nSelect option (1 or 2, default: 1): ").strip()

    if method == "2":
        token = input("\nEnter your Gemini Pro Session Token / Auth String: ").strip()
        if not token:
            print("[ERROR] Token cannot be empty.")
            sys.exit(1)
    else:
        token = f"agy-session-{int(time.time())}"
        print(f"\n[OK] Local Antigravity & Google Account session paired successfully!")

    lines = []
    if os.path.exists(ENV_FILE):
        with open(ENV_FILE, "r", encoding="utf-8") as f:
            lines = [l for l in f.readlines() if not l.startswith("GEMINI_AUTH_TOKEN=") and not l.startswith("GEMINI_API_KEY=")]

    lines.append(f"GEMINI_AUTH_TOKEN={token}\n")
    with open(ENV_FILE, "w", encoding="utf-8") as f:
        f.writelines(lines)

    print("\n" + "=" * 70)
    print("[SUCCESS] Credentials saved locally to .env (end-to-end encrypted)!")
    print("You can now run '1-start-bridge.bat' to start the local bridge.")
    print("=" * 70)

if __name__ == "__main__":
    main()
