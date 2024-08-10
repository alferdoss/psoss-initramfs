# Makefile for creating initramfs

# Directories
SRC_DIR := src
BUILD_DIR := build

# Output file
OUTPUT := $(BUILD_DIR)/initramfs.cpio.gz

# Phony targets
.PHONY: all clean

# Default target
all: $(OUTPUT)

# Create initramfs
$(OUTPUT): $(SRC_DIR)
	@echo "Making output directory"
	@mkdir -p $(BUILD_DIR)
	@echo "Building initramfs.cpio.gz"
	@cd $(SRC_DIR) && find . | cpio --owner=0:0 -o -H newc | gzip -9 > ../$(OUTPUT)
	@echo "Created $(OUTPUT)!"

# Check if the cpio archive is valid
check: $(OUTPUT)
	@gunzip -c $(OUTPUT) | cpio -it
	@echo "Checked $(OUTPUT): Valid"

# Clean up
clean:
	@rm -rf $(BUILD_DIR)
	@echo "Cleaned up build directory"
