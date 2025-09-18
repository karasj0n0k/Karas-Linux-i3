#!/bin/bash
set -x  # Debug output

# ===== CONFIG =====
TMPBG="/tmp/screen.png"
ICONTMP="/tmp/icon.png"
ICON="/home/karas/.i3/Scripts/i3lock/Lock.png"  # Absolute path to your icon
LOGFILE="/tmp/i3lock_debug.log"

# Absolute paths to commands
SCROT="/usr/bin/scrot"
CONVERT="/usr/bin/convert"
XDPI="/usr/bin/xdpyinfo"
I3LOCK="/usr/bin/i3lock"

# ===== LOGGING =====
exec > >(tee -a "$LOGFILE") 2>&1
echo "[$(date)] Lockscreen script started"

# ===== CLEANUP ON EXIT =====
trap 'rm -f "$TMPBG" "$ICONTMP"' EXIT

# ===== DELAY TO AVOID BLACK SCREENSHOT =====
sleep 0.2

# ===== TAKE SCREENSHOT =====
if ! $SCROT "$TMPBG"; then
    echo "ERROR: scrot failed"
    exit 1
fi

# ===== PIXELATE BACKGROUND =====
if ! $CONVERT "$TMPBG" -scale 10% -filter point -scale 1000% "$TMPBG"; then
    echo "ERROR: convert scale failed"
    exit 1
fi

# ===== ADD ICON =====
if [[ -f "$ICON" ]]; then
    echo "Compositing icon $ICON in the center"
    SCREEN_WIDTH=$($XDPI | awk '/dimensions/{print $2}' | cut -d'x' -f1)
    ICON_SIZE=$(( SCREEN_WIDTH / 10 ))
    if ! $CONVERT "$ICON" -resize "${ICON_SIZE}x${ICON_SIZE}" "$ICONTMP"; then
        echo "ERROR: icon resize failed"
        exit 1
    fi
    if ! $CONVERT "$TMPBG" "$ICONTMP" -gravity center -compose over -composite "$TMPBG"; then
        echo "ERROR: icon composite failed"
        exit 1
    fi
else
    echo "WARNING: Icon file not found at $ICON"
fi

# ===== LOCK SCREEN =====
if ! $I3LOCK -i "$TMPBG"; then
    echo "ERROR: i3lock failed"
    exit 1
fi

echo "[$(date)] Lockscreen script finished"

