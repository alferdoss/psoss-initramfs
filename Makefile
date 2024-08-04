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
	mkdir -p $(BUILD_DIR)
	cd $(SRC_DIR) && find . | cpio -o -H newc | gzip -9 > ../$(OUTPUT)
	@echo "Created $(OUTPUT)"

# Clean up
clean:
	rm -rf $(BUILD_DIR)
	@echo "Cleaned up build directory"
