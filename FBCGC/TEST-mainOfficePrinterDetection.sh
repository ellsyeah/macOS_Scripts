#!/bin/zsh

PRINTER_NAME="CanonMF3010"

if lpstat -p "$PRINTER_NAME" >/dev/null 2>&1; then
    echo "Printer '$PRINTER_NAME' exists"
    exit 0
else
    echo "Printer '$PRINTER_NAME' is missing"
    exit 1
fi