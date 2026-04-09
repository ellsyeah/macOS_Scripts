#!/bin/zsh

set -euo pipefail

########################################
# Konica Minolta bizhub C650i
# Queue Name: Main_Office
# Display Name: Main Office
########################################

PRINTER_NAME="Main_Office"
PRINTER_DISPLAY_NAME="Main Office"
PRINTER_LOCATION="Main Office"

PRINTER_URI="ipps://192.192.3.25/ipp/print"
LOG_FILE="/var/log/km-main-office-printer.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "==== $(date) Starting printer deployment ===="

# Ensure CUPS is running
launchctl load -w /System/Library/LaunchDaemons/org.cups.cupsd.plist >/dev/null 2>&1 || true

# Wait for Konica PPD to appear
echo "Searching for Konica Minolta C650i PPD..."
PPD_PATH=""

for i in {1..30}; do
    PPD_PATH=$(find /Library/Printers/PPDs -type f \
        \( -iname "*C650i*.ppd" -o -iname "*C650i*.ppd.gz" -o -iname "*KONICA*MINOLTA*C650i*" \) \
        2>/dev/null | head -n 1 || true)

    if [[ -n "$PPD_PATH" ]]; then
        break
    fi

    echo "PPD not found yet, waiting..."
    sleep 10
done

if [[ -z "$PPD_PATH" ]]; then
    echo "ERROR: No C650i PPD found"
    exit 1
fi

echo "Using PPD: $PPD_PATH"

# Remove existing managed queue if present
if lpstat -p "$PRINTER_NAME" >/dev/null 2>&1; then
    echo "Removing existing printer: $PRINTER_NAME"
    lpadmin -x "$PRINTER_NAME" || true
    sleep 2
fi

# Create printer
echo "Creating printer queue..."
lpadmin \
  -p "$PRINTER_NAME" \
  -E \
  -v "$PRINTER_URI" \
  -P "$PPD_PATH" \
  -D "$PRINTER_DISPLAY_NAME" \
  -L "$PRINTER_LOCATION" \
  -o printer-is-shared=false

cupsenable "$PRINTER_NAME"
cupsaccept "$PRINTER_NAME"

echo "Validating printer..."
lpstat -l -p "$PRINTER_NAME" || true
lpstat -v "$PRINTER_NAME" || true

echo "==== $(date) Printer deployment complete ===="
exit 0