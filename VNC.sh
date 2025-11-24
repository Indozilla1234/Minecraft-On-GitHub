 #!/bin/bash

# Kill any old VNC or Websockify processes
echo "Killing old processes..."
kill $(lsof -t -i :5901) 2>/dev/null
kill $(lsof -t -i :6080) 2>/dev/null

# Start X virtual framebuffer
echo "Starting Xvfb..."
Xvfb :1 -screen 0 1024x768x24 &

# Give it a second to start
sleep 2
export DISPLAY=:1

# Start x11vnc
echo "Starting x11vnc..."
x11vnc -display :1 -nopw -forever -rfbport 5901 -noxdamage &

# Give x11vnc a second to bind the port
sleep 2

# Start websockify
echo "Starting websockify..."
websockify 6080 localhost:5901 &

echo "Setup complete. Open NoVNC at http://localhost:6080 and press Connect."
