#!/bin/zsh

echo "Configured printers:"
echo "===================="

lpstat -p 2>/dev/null | awk '{print $2}' | while IFS= read -r PRINTER; do
    URI=$(lpstat -v "$PRINTER" 2>/dev/null | sed -n 's/^device for .*: //p')

    if [[ -z "$URI" ]]; then
        TYPE="Unknown"
    elif [[ "$URI" == dnssd://* ]]; then
        TYPE="Bonjour / AirPrint"
    elif [[ "$URI" == ipp://* ]]; then
        TYPE="IPP"
    elif [[ "$URI" == ipps://* ]]; then
        TYPE="IPPS"
    elif [[ "$URI" == lpd://* ]]; then
        TYPE="LPD"
    elif [[ "$URI" == socket://* ]]; then
        TYPE="Socket / JetDirect"
    else
        TYPE="Other"
    fi

    echo "Printer: $PRINTER"
    echo "URI:     $URI"
    echo "Type:    $TYPE"
    echo ""
done