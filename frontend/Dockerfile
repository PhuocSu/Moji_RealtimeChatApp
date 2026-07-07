# ==========================================
# Stage 1: Build React app
# ==========================================
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files trước (tận dụng layer cache)
COPY package*.json ./

# Cài tất cả dependencies (cần devDeps để build)
RUN npm ci --fetch-retries=5 --fetch-retry-mintimeout=20000 --fetch-retry-maxtimeout=120000 

# Copy toàn bộ source code
COPY . .

# Build React app thành static files (output vào thư mục /app/build)
# Truyền VITE_API_URL hoặc REACT_APP_API_URL vào lúc build nếu cần
ARG REACT_APP_API_URL=http://localhost:5173
ENV REACT_APP_API_URL=$REACT_APP_API_URL

RUN npm run build

# ==========================================
# Stage 2: Serve bằng Nginx (image rất nhỏ ~25MB)
# Stage builder node:20-alpine ~180MB sẽ bị loại bỏ hoàn toàn
# ==========================================
FROM nginx:1.27-alpine AS production

# Xóa config mặc định của nginx
RUN rm -rf /etc/nginx/conf.d/default.conf

# Copy custom nginx config (xử lý React Router, gzip, security headers)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy static files đã build từ stage 1
COPY --from=builder /app/dist /usr/share/nginx/html

# Tạo user không phải root
RUN addgroup -g 1001 -S nginxgroup && \
    adduser  -S nginxuser -u 1001 -G nginxgroup && \
    chown -R nginxuser:nginxgroup /usr/share/nginx/html && \
    chown -R nginxuser:nginxgroup /var/cache/nginx && \
    touch /var/run/nginx.pid && \
    chown -R nginxuser:nginxgroup /var/run/nginx.pid

USER nginxuser

EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:80 || exit 1

CMD ["nginx", "-g", "daemon off;"]
