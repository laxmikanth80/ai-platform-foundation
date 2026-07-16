"""Minimal service — proves the pipeline (build -> ECR -> Argo CD -> EKS) end to end.

Deliberately trivial: the point of Ch.1 is the platform around this app, not the app itself.
"""

from fastapi import FastAPI

from platform_foundation import __version__

app = FastAPI(title="platform-foundation")


@app.get("/")
def hello() -> dict:
    return {"message": "hello from the AI platform foundation", "version": __version__}


@app.get("/healthz")
def healthz() -> dict:
    """Kubernetes liveness/readiness probe target."""
    return {"status": "ok"}
