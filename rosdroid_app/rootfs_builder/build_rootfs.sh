#!/usr/bin/env bash
set -e

# Configuration
OUTPUT_TAR="rosdroid-ubuntu26-lyrical-arm64.tar.gz"

echo "=========================================================="
echo " Building Rosdroid Ubuntu 26.04 + ROS 2 Lyrical Rootfs"
echo "=========================================================="

# Check for docker
if ! command -v docker >/dev/null 2>&1; then
    echo "Error: docker is required but not installed." >&2
    exit 1
fi

# Ensure QEMU multiarch is registered for cross-building ARM64
echo "Registering QEMU binfmt handlers..."
docker run --privileged --rm tonistiigi/binfmt --install all || true

# Build the ARM64 image and export its root filesystem directly.
echo "Building ARM64 Docker container..."
TMP_TAR="${OUTPUT_TAR%.gz}"
rm -f "$TMP_TAR" "$OUTPUT_TAR"
docker buildx build --platform linux/arm64 --output "type=tar,dest=${TMP_TAR}" .

echo "Compressing rootfs..."
gzip -9 "$TMP_TAR"

echo "=========================================================="
echo " Rootfs archive created successfully: $OUTPUT_TAR"
echo " Size: $(du -h "$OUTPUT_TAR" | cut -f1)"
echo "=========================================================="
