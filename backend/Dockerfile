# ==========================================
# Stage 1: Install dependencies
# ==========================================
FROM node:20-alpine AS deps

WORKDIR /app

# Copy package files để tận dụng cache
COPY package*.json ./

# Cài production dependencies (bỏ devDependencies)
RUN npm ci --only=production

# ==========================================
# Stage 2: Production image
# ==========================================
FROM node:20-alpine AS production

# Tạo user không phải root để chạy app (bảo mật)
RUN addgroup -g 1001 -S nodejs && \
    adduser  -S nodeuser -u 1001 -G nodejs

WORKDIR /app

# Copy dependencies đã cài từ stage deps
COPY --from=deps --chown=nodeuser:nodejs /app/node_modules ./node_modules

# Copy toàn bộ source code (JS thuần không cần build)
COPY --chown=nodeuser:nodejs . .

# Chuyển sang user không phải root
USER nodeuser

# Expose port app lắng nghe
EXPOSE 5001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD wget -qO- http://localhost:5001/health || exit 1

# Khởi động app (JS thuần)
CMD ["node", "src/server.js"]
