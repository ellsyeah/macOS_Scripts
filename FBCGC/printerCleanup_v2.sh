#!/bin/zsh

set -euo pipefail

TARGET_IP="192.192.3.25"
TARGET_QUEUE="Main_Office"

echo "==== $(date) Starting printer cleanup ===="

# Get all configured printer queue names
for p in $(lpstat -p 2>/dev/null | awk '{print $2}'); do
    URI=$(lpstat -v "$p" 2>/dev/null | awk '{print $4}')
    LOWER_NAME=$(printf '%s' "$p" | tr '[:upper:]' '[:lower:]')
    LOWER_URI=$(printf '%s' "$URI" | tr '[:upper:]' '[:lower:]')

    # Preserve fax queues
    if [[ "$LOWER_NAME" == *fax* || "$LOWER_URI" == *fax* ]]; then
        echo "Keeping fax queue: $p ($URI)"
        continue
    fi

    REMOVE_QUEUE=false

    # Remove any existing managed queue so it can be recreated cleanly
    if [[ "$p" == "$TARGET_QUEUE" ]]; then
        REMOVE_QUEUE=true
    fi

    # Remove direct queues pointing at the target printer IP
    if [[ "$URI" == *"$TARGET_IP"* ]]; then
        REMOVE_QUEUE=true
    fi

    # Remove Konica Bonjour / AirPrint print queues
    if [[ "$URI" == dnssd://*KONICAMINOLTA* ]]; then
        REMOVE_QUEUE=true
    fi

    if [[ "$REMOVE_QUEUE" == true ]]; then
        echo "Removing queue: $p ($URI)"
        lpadmin -x "$p" || true
    else
        echo "Keeping unrelated queue: $p ($URI)"
    fi
done

echo "==== $(date) Printer cleanup complete ===="
exit 0