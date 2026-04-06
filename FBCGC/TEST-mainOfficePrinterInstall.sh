#!/bin/zsh

set -euo pipefail

########################################
# Canon MF3010
# Printer Name: Canon MF3010
########################################

PRINTER_NAME="CanonMF3010"
PRINTER_DISPLAY_NAME="CanonMF3010"
PRINTER_LOCATION="TestNetwork"

# Try IPP first if the printer supports it
PRINTER_URI="socket://192.168.68.10"

LOG_FILE="/var/log/canon-mf3010-test-printer.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "==== $(date) Starting printer deployment ===="

# Ensure CUPS is running
launchctl load -w /System/Library/LaunchDaemons/org.cups.cupsd.plist >/dev/null 2>&1 || true

# Wait for Canon PPD to appear
echo "Searching for Canon MF3010 PPD..."
PPD_PATH=""

for i in {1..30}; do
    PPD_PATH=$(find /Library/Printers/PPDs -type f \
        \( -iname "*MF3010*.ppd" -o -iname "*MF3010*.ppd.gz" -o -iname "*Canon*MF3010*" -o -iname "*Canon*ImageClass*MF3010*" \) \
        2>/dev/null | head -n 1 || true)

    if [[ -n "$PPD_PATH" ]]; then
        break
    fi

    echo "PPD not found yet, waiting..."
    sleep 10
done

if [[ -z "$PPD_PATH" ]]; then
    echo "ERROR: No Canon MF3010 PPD found"
    exit 1
fi

echo "Using PPD: $PPD_PATH"

# Remove existing printer with same name
if lpstat -p "$PRINTER_NAME" >/dev/null 2>&1; then
    echo "Removing existing printer: $PRINTER_NAME"
    lpadmin -x "$PRINTER_NAME" || true
    sleep 2
fi

# Debug printer name
printf 'DEBUG PRINTER_NAME: [%s]\n' "$PRINTER_NAME"
printf '%s' "$PRINTER_NAME" | od -c

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

# Enable printer
cupsenable "$PRINTER_NAME"
cupsaccept "$PRINTER_NAME"

echo "Validating printer..."
lpstat -l -p "$PRINTER_NAME" || true
lpstat -v "$PRINTER_NAME" || true

echo "==== $(date) Printer deployment complete ===="
exit 0