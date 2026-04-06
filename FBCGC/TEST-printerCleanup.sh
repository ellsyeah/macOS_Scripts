#!/bin/zsh

PRINTER_NAME="CanonMF3010"

for p in $(lpstat -p | awk '{print $2}'); do
    URI=$(lpstat -v "$p" 2>/dev/null | awk '{print $4}')
    if [[ "$p" == "$PRINTER_NAME" ]]; then
        echo "Removing queue: $p ($URI)"
        lpadmin -x "$p"
    fi
done