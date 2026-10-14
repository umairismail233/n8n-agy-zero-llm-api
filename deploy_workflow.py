import os
import sys
import json
import sqlite3
import argparse
import urllib.request
import urllib.error

ENV_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".env")

def load_env():
    env = {}
    if os.path.exists(ENV_PATH):
        with open(ENV_PATH, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    k, v = line.split("=", 1)
                    env[k.strip()] = v.strip()
    return env

ENV = load_env()
N8N_BASE_URL = ENV.get("N8N_BASE_URL", "http://127.0.0.1:5678").rstrip("/")
N8N_API_KEY = ENV.get("N8N_API_KEY", "")

def get_headers():
    return {
        "X-N8N-API-KEY": N8N_API_KEY,
        "Content-Type": "application/json"
    }

def list_workflows():
    """Lists all workflows using REST API or fallback to SQLite database."""
    if N8N_API_KEY:
        url = f"{N8N_BASE_URL}/api/v1/workflows"
        req = urllib.request.Request(url, headers=get_headers())
        try:
            with urllib.request.urlopen(req, timeout=10) as resp:
                data = json.loads(resp.read().decode("utf-8"))
                workflows = data.get("data", [])
                print(f"\nFound {len(workflows)} Workflows in n8n via REST API:")
                print("--------------------------------------------------------------------------------")
                for w in workflows:
                    status = "ACTIVE" if w.get("active") else "INACTIVE"
                    print(f"• ID: {w['id']} | [{status}] {w['name']}")
                print("--------------------------------------------------------------------------------\n")
                return workflows
        except Exception as e:
            print(f"[!] REST API list failed ({str(e)}). Querying local SQLite database...")

    # SQLite fallback
    db_path = os.path.expanduser(r"~\.n8n\database.sqlite")
    if os.path.exists(db_path):
        conn = sqlite3.connect(db_path)
        c = conn.cursor()
        c.execute("SELECT id, name, active FROM workflow_entity")
        rows = c.fetchall()
        print(f"\nFound {len(rows)} Workflows in n8n (SQLite Database):")
        print("--------------------------------------------------------------------------------")
        for r in rows:
            status = "ACTIVE" if r[2] else "INACTIVE"
            print(f"• ID: {r[0]} | [{status}] {r[1]}")
        print("--------------------------------------------------------------------------------\n")
        conn.close()
        return rows
    else:
        print("[!] No n8n database or API key available.")
        return []

def get_workflow(workflow_id: str):
    """Retrieves full workflow JSON."""
    if N8N_API_KEY:
        url = f"{N8N_BASE_URL}/api/v1/workflows/{workflow_id}"
        req = urllib.request.Request(url, headers=get_headers())
        try:
            with urllib.request.urlopen(req, timeout=10) as resp:
                data = json.loads(resp.read().decode("utf-8"))
                return data
        except Exception:
            pass

    db_path = os.path.expanduser(r"~\.n8n\database.sqlite")
    if os.path.exists(db_path):
        conn = sqlite3.connect(db_path)
        c = conn.cursor()
        c.execute("SELECT nodes, connections, name, active FROM workflow_entity WHERE id=?", (workflow_id,))
        row = c.fetchone()
        conn.close()
        if row:
            return {
                "id": workflow_id,
                "name": row[2],
                "active": bool(row[3]),
                "nodes": json.loads(row[0]),
                "connections": json.loads(row[1])
            }
    return None

def deploy_workflow(json_file_path: str):
    """Creates or updates a workflow in n8n."""
    if not os.path.exists(json_file_path):
        print(f"[ERROR] Workflow file not found: {json_file_path}")
        return False

    with open(json_file_path, "r", encoding="utf-8") as f:
        payload = json.load(f)

    # Clean payload
    payload_to_send = {
        "name": payload.get("name", "New Automated Workflow"),
        "nodes": payload.get("nodes", []),
        "connections": payload.get("connections", {}),
        "settings": payload.get("settings", {})
    }

    if N8N_API_KEY:
        url = f"{N8N_BASE_URL}/api/v1/workflows"
        req = urllib.request.Request(
            url,
            data=json.dumps(payload_to_send).encode("utf-8"),
            headers=get_headers(),
            method="POST"
        )
        try:
            with urllib.request.urlopen(req, timeout=15) as resp:
                res_data = json.loads(resp.read().decode("utf-8"))
                wid = res_data.get("id") or res_data.get("data", {}).get("id")
                print(f"[SUCCESS] Workflow deployed to n8n canvas! ID: {wid}")
                print(f"Access Canvas at: {N8N_BASE_URL}/workflow/{wid}")
                return True
        except urllib.error.HTTPError as e:
            err_body = e.read().decode("utf-8")
            print(f"[!] REST API deploy failed (HTTP {e.code}): {err_body}")
    
    print("[!] Fallback: You can import this JSON directly into n8n UI -> Workflows -> Import from File.")
    return False

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Antigravity n8n Workflow Orchestrator")
    parser.add_argument("action", choices=["list", "get", "deploy"], help="Action to perform")
    parser.add_argument("target", nargs="?", default="", help="Workflow ID or JSON file path")
    args = parser.parse_args()

    if args.action == "list":
        list_workflows()
    elif args.action == "get":
        if not args.target:
            print("Usage: python deploy_workflow.py get <workflow_id>")
        else:
            w = get_workflow(args.target)
            print(json.dumps(w, indent=2))
    elif args.action == "deploy":
        if not args.target:
            print("Usage: python deploy_workflow.py deploy <workflow.json>")
        else:
            deploy_workflow(args.target)
