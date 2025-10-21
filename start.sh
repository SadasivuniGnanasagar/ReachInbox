#!/bin/bash
# Quick start script for ReachInbox Onebox

echo "🚀 Starting ReachInbox Onebox..."

# Navigate to project root
cd "$(dirname "$0")"

# Start backend
echo "📦 Starting backend..."
pkill -f 'node -r ts-node' 2>/dev/null
nohup node -r ts-node/register src/index.ts > backend.log 2>&1 &
BACKEND_PID=$!
echo "   Backend PID: $BACKEND_PID"

# Wait for backend to start
sleep 3

# Start frontend
echo "🎨 Starting frontend..."
cd frontend
pkill -f vite 2>/dev/null
nohup npm run dev > frontend.log 2>&1 &
FRONTEND_PID=$!
echo "   Frontend PID: $FRONTEND_PID"

# Wait for frontend to start
sleep 3

echo ""
echo "✅ Project started successfully!"
echo ""
echo "🌐 Access the application:"
echo "   Frontend:  http://localhost:5173"
echo "   Backend:   http://localhost:3000/api/emails"
echo ""
echo "📝 View logs:"
echo "   Backend:   tail -f $(pwd)/../backend.log"
echo "   Frontend:  tail -f $(pwd)/frontend.log"
echo ""
echo "🛑 Stop servers:"
echo "   pkill -f 'node -r ts-node' && pkill -f vite"
echo ""
