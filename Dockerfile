FROM python:3.11-slim AS base

# uv is already the dependency manager locally — reuse it in the image instead
# of introducing a second tool (pip) with different resolution behavior.
COPY --from=ghcr.io/astral-sh/uv:0.5 /uv /uvx /usr/local/bin/

WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

COPY src/ src/

RUN uv sync --frozen --no-dev

# Never run the app as root.
RUN useradd --create-home appuser
USER appuser

EXPOSE 8000

CMD ["uv", "run", "uvicorn", "platform_foundation.app:app", "--host", "0.0.0.0", "--port", "8000"]
