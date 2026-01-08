# Khởi động tất cả services
docker-compose up -d

# Xem logs real-time
docker-compose logs -f backend

# Dừng services
docker-compose down

# Restart một service
docker-compose restart backend