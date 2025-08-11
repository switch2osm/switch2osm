# ---- Build Stage ----
FROM docker.io/python:3.13-bookworm AS builder

# Create non-root user and set up environment
RUN useradd -m builder && \
    mkdir -p /home/builder/site /home/builder/output && \
    chown -R builder:builder /home/builder

WORKDIR /home/builder/site

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential git libcairo2-dev \
    && rm -rf /var/lib/apt/lists/*

USER builder

# Install MkDocs and your theme/plugins
COPY --chown=builder:builder requirements.txt ./
ENV PATH="/home/builder/.local/bin:${PATH}"
RUN pip install --user --no-cache-dir  -r requirements.txt

# Copy mkdocs.yml and other necessary files
COPY --chown=builder:builder . .

# Build the MkDocs site
RUN mkdocs build --strict --site-dir /home/builder/output

# Compress assets for nginx gzip_static support
RUN find /home/builder/output -type f -size +256c \( -name "*.html" -o -name "*.css" -o -name "*.js" -o -name "*.xml" -o -name "*.json" -o -name "*.svg" -o -name "*.ttf" -o -name "*.woff2" -o -name "*.woff" -o -name "*.eot" -o -name "*.otf" -o -name "*.pbf" \) -print0 | xargs -0 -P4 --no-run-if-empty gzip -9k --force

# ---- Final Stage: Webserver ----
FROM ghcr.io/nginxinc/nginx-unprivileged:stable-alpine AS webserver

# Copy built site from builder stage
COPY --from=builder /home/builder/output /usr/share/nginx/html

RUN echo "absolute_redirect off;" >/etc/nginx/conf.d/no-absolute_redirect.conf
RUN echo "gzip_static on; gzip_proxied any;" >/etc/nginx/conf.d/gzip_static.conf
# FIXME: mkdocs-static-i18n incorrectly translating 404 using last language - https://github.com/ultrabug/mkdocs-static-i18n/issues/284
# RUN sed -Ei'' 's/#error_page *404 +.*/error_page 404 \/404.html;/' /etc/nginx/conf.d/default.conf || true

# Test nginx configuration
RUN nginx -t

EXPOSE 8080
