#!/bin/zsh

PRINTER_NAME="Main_Office"

if lpstat -p "$PRINTER_NAME" >/dev/null 2>&1; then
    echo "Removing existing queue: $PRINTER_NAME"
    lpadmin -x "$PRINTER_NAME"
fi