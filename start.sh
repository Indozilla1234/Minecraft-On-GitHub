#!/bin/bash
echo "Clearing old data..."

# Kill old processes quietly
pkill -f websockify 2>/dev/null
pkill -f x11vnc 2>/dev/null
pkill -f Xvfb 2>/dev/null

# Remove old lock files if Xvfb thinks display 1 is in use
rm -f /tmp/.X1-lock

# Start Xvfb on display :1 (headless framebuffer)
echo "Starting Xvfb..."
Xvfb :1 -screen 0 1024x768x24 &

export DISPLAY=:1
sleep 2  # give Xvfb a moment to initialize

# Start Openbox for a lightweight window manager
echo "Starting Openbox..."
openbox-session &

sleep 2  # let Openbox start

# Start x11vnc once
echo "Starting x11vnc..."
x11vnc -display :1 -nopw -forever -rfbport 5901 -noxdamage -ncache 10 &

# Start websockify once
echo "Starting websockify..."
websockify --web=/usr/share/novnc 6080 localhost:5901 &

# Run your Node app (Minecraft launcher)
echo "Starting Minecraft..."
node index.js
sh start.sh

if [ $? -ne 0 ]; then
    echo "Minecraft failed to start!"
fi
