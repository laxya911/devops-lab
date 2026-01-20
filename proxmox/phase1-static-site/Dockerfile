# ============================================================================
# Dockerfile for Phase 1: Static Website
# ============================================================================
# This Dockerfile creates a lightweight Nginx container serving static HTML/CSS
# Uses multi-stage build for smaller final image size

# ============================================================================
# Stage 1: Build stage (optional for static sites, but good practice)
# ============================================================================
FROM nginx:alpine AS builder

# Copy static files to a temporary location
# This stage could be used for building assets if needed (e.g., npm build)
COPY index.html /tmp/
COPY style.css /tmp/

# ============================================================================
# Stage 2: Production stage
# ============================================================================
FROM nginx:alpine

# Metadata labels (good practice for image management)
LABEL maintainer="devops-lab"
LABEL description="Phase 1 Static Website for K8s Testing"
LABEL version="1.0"

# Remove default Nginx static files
# This ensures only our custom content is served
RUN rm -rf /usr/share/nginx/html/*

# Copy our static files from builder stage to Nginx html directory
# /usr/share/nginx/html is the default Nginx document root
COPY --from=builder /tmp/index.html /usr/share/nginx/html/
COPY --from=builder /tmp/style.css /usr/share/nginx/html/

# Create a custom Nginx configuration (optional)
# This adds server info and improves logging
RUN echo 'server { \
    listen 80; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ =404; \
    } \
    # Add custom headers for debugging \
    add_header X-Served-By $hostname; \
}' > /etc/nginx/conf.d/default.conf

# Expose port 80 for HTTP traffic
# This is informational - actual port mapping happens in K8s Service
EXPOSE 80

# Health check (Docker native)
# Checks if Nginx is responding every 30 seconds
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start Nginx in foreground mode
# -g 'daemon off;' keeps Nginx running in foreground (required for containers)
CMD ["nginx", "-g", "daemon off;"]

# ============================================================================
# Build Instructions:
# ============================================================================
# docker build -t static-site:v1.0 .
# docker run -p 8080:80 static-site:v1.0
# Access: http://localhost:8080
