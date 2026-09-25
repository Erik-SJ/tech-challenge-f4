from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os
import urllib.request

GITHUB_TOKEN = os.environ["GITHUB_TOKEN"]
GITHUB_REPOSITORY = os.environ["GITHUB_REPOSITORY"]

class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length)

        try:
            alertmanager = json.loads(body)
            alerts = alertmanager.get("alerts", [])

            if not alerts:
                raise ValueError("No alerts received")

            alert = alerts[0]
            labels = alert.get("labels", {})
            annotations = alert.get("annotations", {})

            payload = {
                "event_type": "alertmanager-jira",
                "client_payload": {
                    "alertname": labels.get("alertname", "UnknownAlert"),
                    "service": labels.get("service", "unknown"),
                    "description": annotations.get(
                        "description",
                        annotations.get("summary", "Alertmanager alert")
                    )
                }
            }

            request = urllib.request.Request(
                f"https://api.github.com/repos/{GITHUB_REPOSITORY}/dispatches",
                data=json.dumps(payload).encode(),
                headers={
                    "Authorization": f"Bearer {GITHUB_TOKEN}",
                    "Accept": "application/vnd.github+json",
                    "Content-Type": "application/json",
                    "X-GitHub-Api-Version": "2022-11-28"
                },
                method="POST"
            )

            with urllib.request.urlopen(request) as response:
                if response.status not in (200, 201, 204):
                    raise RuntimeError(f"GitHub returned {response.status}")

            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"GitHub dispatch sent")

        except Exception as error:
            self.send_response(500)
            self.end_headers()
            self.wfile.write(str(error).encode())

    def log_message(self, format, *args):
        return

HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
