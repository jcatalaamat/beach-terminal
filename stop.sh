#!/bin/bash
echo "Stopping Beach Terminal..."
pkill ttyd 2>/dev/null
pkill -f "server.py" 2>/dev/null
echo "Stopped."
