#!/bin/bash

SOURCE="/etc"
DEST="/tmp/company-backup"

mkdir -p "$DEST"

tar -czf "$DEST/etc-backup.tar.gz" "$SOURCE"

echo "Backup completed"
echo Backup Process Started
