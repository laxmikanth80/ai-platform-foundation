FROM python:3.11-slim AS base

# uv is already the dependency manager locally — reuse it in the image instead
# of introducing a second tool (pip) with different resolution behavior.
COPY --from=ghcr.io/astral-sh/uv:0.5 /uv /uvx /usr/local/bin/

WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

COPY src/ src/

RUN uv sync --frozen --no-dev

# Never run the app as root. The venv was built as root above, so it must be
# handed off to appuser explicitly — otherwise anything that tries to touch
# it at runtime (including uv's own sync-check) hits Permission denied.
RUN useradd --create-home appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

# Deliberately NOT "uv run" here: uv run re-checks/re-syncs the environment
# against the lockfile on every invocation, which is pointless work in a
# container that was already correctly built, and is exactly what triggered
# the permission error (it tried to rewrite the editable-install .pth file
# at runtime as a non-root user). Executing the venv's own installed binary
# directly skips that check entirely.
CMD ["/app/.venv/bin/uvicorn", "platform_foundation.app:app", "--host", "0.0.0.0", "--port", "8000"]
