#!/bin/bash
set -e

brew install pam-reattach

sudo tee /etc/pam.d/sudo_local > /dev/null <<'EOF'
EOF

sudo chmod 444 /etc/pam.d/sudo_local
