#!/bin/bash

echo "🚀 Setting up Monitoring System with Uptime Kuma and Redis"

# Create necessary directories
mkdir -p uptime-kuma-data
mkdir -p redis-data

# Start monitoring services
echo "📊 Starting Uptime Kuma and Redis..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Check if services are running
echo "🔍 Checking service status..."
docker-compose ps

# Display access information
echo ""
echo "✅ Monitoring Setup Complete!"
echo ""
echo "🌐 Access URLs:"
echo "   Uptime Kuma: http://localhost:3001"
echo "   Redis Commander: http://localhost:8081"
echo ""
echo "📝 Next Steps:"
echo "   1. Open Uptime Kuma at http://localhost:3001"
echo "   2. Create your first admin account"
echo "   3. Add your Slack webhook URL in Settings > Notifications"
echo "   4. Configure monitors for your services"
echo ""
echo "🔧 Redis Cache Info:"
echo "   Host: localhost"
echo "   Port: 6379"
echo "   Management: http://localhost:8081"
echo ""
echo "📋 To stop monitoring:"
echo "   docker-compose down"
echo ""
echo "📋 To view logs:"
echo "   docker-compose logs -f" 