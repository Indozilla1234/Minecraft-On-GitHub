#!/bin/bash
echo "Starting Minecraft environment

# --- Installation and Dependency Checks ---
# Ensure necessary tools are installed
sudo apt update && \
dpkg -s xvfb >/dev/null 2>&1 || sudo apt install -y xvfb && \
dpkg -s openbox >/dev/null 2>&1 || sudo apt install -y openbox && \
dpkg -s x11vnc >/dev/null 2>&1 || sudo apt install -y x11vnc && \
dpkg -s python3-websockify >/dev/null 2>&1 || sudo apt install -y python3-websockify && \
dpkg -s nodejs >/dev/null 2>&1 || sudo apt install -y nodejs && \
dpkg -s npm >/dev/null 2>&1 || sudo apt install -y npm && \
dpkg -s novnc >/dev/null 2>/dev/null || sudo apt install -y novnc && \
dpkg -s xfonts-base >/dev/null 2>&1 || sudo apt install -y xfonts-base 

# --- Kill ALL processes and Cleanup ---
echo "Cleaning up previous processes..."
# Use pkill -KILL to forcefully terminate stubborn processes
pkill -KILL -f websockify 2>/dev/null
pkill -KILL -f x11vnc 2>/dev/null
pkill -KILL -f Xvfb 2>/dev/null
pkill -KILL -f xdotool 2>/dev/null
rm -f /tmp/.X1-lock
sleep 1 # Wait a moment to ensure ports are released

# --- Xvfb Startup ---
echo "Starting Xvfb with Cursor Font Path..."
Xvfb :1 -screen 0 1024x768x24 -fp /usr/share/fonts/X11/misc &

export DISPLAY=:1
sleep 5

# Start Openbox (Warnings about menu/PyXDG are non-fatal and ignored)
echo "Starting Openbox..."
openbox-session &
sleep 2

# --- x11vnc Startup (Stable) ---
echo "Starting x11vnc with stable settings..."
# We must use -quiet to suppress minor warnings and run it in the background
x11vnc -display :1 -nopw -forever -rfbport 5901 -noxdamage -quiet & 

# --- STAGE CHECK: Wait for VNC Server (FIXED SYNTAX) ---
echo "Waiting for x11vnc to open port 5901..."
TIMEOUT=30
i=0
# Use robust while loop syntax
while [ $i -lt $TIMEOUT ]; do
    if netstat -tuln | grep 5901 > /dev/null; then
        echo "Port 5901 is listening. Continuing."
        break
    fi
    i=$((i+1))
    if [ $i -eq $TIMEOUT ]; then
        echo "Error: x11vnc failed to start on port 5901 within $TIMEOUT seconds."
        exit 1
    fi
    sleep 1
done

# Start websockify ONLY after VNC port is confirmed open
echo "Starting websockify..."
websockify --web=/usr/share/novnc 8080 localhost:5901 &

# Run your Node app (Minecraft launcher)
echo "Starting Minecraft..."
node index.js

if [ $? -ne 0 ]; then
    echo "Minecraft failed to start!"
fi
