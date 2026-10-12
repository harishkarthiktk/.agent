#!/usr/bin/env python3
"""
verify_frames.py - verify quality of extracted PNG frames.

Requires: source ~/.venv_gen/bin/activate first for PIL/OpenCV/imagehash.

Usage:
  source ~/.venv_gen/bin/activate
  ./verify_frames.py <frames_dir> <expected_width> <expected_height> [output_report]

Runs objective checks on extracted frames:
- File exists and has non-trivial size
- Not blank/black (mean brightness check)
- Not blurry (Laplacian variance if available, otherwise skipped)
- Resolution matches expected
- No unintended duplicates (perceptual hash comparison)

Writes results to verification_report.txt in the documented format, or to a
custom output path if provided.
"""

import os
import sys
import json
from pathlib import Path
from collections import defaultdict

try:
    from PIL import Image, ImageFilter, ImageOps
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False

try:
    import cv2
    import numpy as np
    OPENCV_AVAILABLE = True
except ImportError:
    OPENCV_AVAILABLE = False

try:
    from imagehash import phash
    IMAGEHASH_AVAILABLE = True
except ImportError:
    IMAGEHASH_AVAILABLE = False


def get_file_size(filepath):
    """Return file size in bytes."""
    return os.path.getsize(filepath)


def check_brightness(filepath):
    """
    Compute mean pixel brightness (Y channel if available, else grayscale).
    Returns (mean_brightness, is_acceptable).
    Frames with mean brightness < 20 are likely black/blank.
    """
    if not PIL_AVAILABLE:
        return None, None

    try:
        img = Image.open(filepath).convert("L")  # Grayscale
        pixels = list(img.getdata())
        mean_brightness = sum(pixels) // len(pixels) if pixels else 0
        # Very dark frames (< 20) are likely black/fade transitions
        is_acceptable = mean_brightness >= 20
        return mean_brightness, is_acceptable
    except Exception as e:
        return None, None


def check_blur(filepath):
    """
    Estimate blur via Laplacian variance (requires OpenCV).
    Returns (variance, is_acceptable).
    Blurry frames have Laplacian variance < ~100.
    """
    if not OPENCV_AVAILABLE:
        return None, None

    try:
        img = cv2.imread(filepath, cv2.IMREAD_GRAYSCALE)
        if img is None:
            return None, None
        laplacian_var = cv2.Laplacian(img, cv2.CV_64F).var()
        # Threshold of 100 is heuristic; adjust if needed
        is_acceptable = laplacian_var >= 100
        return laplacian_var, is_acceptable
    except Exception as e:
        return None, None


def get_perceptual_hash(filepath):
    """Compute perceptual hash for duplicate detection."""
    if not IMAGEHASH_AVAILABLE or not PIL_AVAILABLE:
        return None

    try:
        img = Image.open(filepath)
        return str(phash(img))
    except Exception as e:
        return None


def get_resolution(filepath):
    """Return (width, height) of the image."""
    if not PIL_AVAILABLE:
        return None, None

    try:
        img = Image.open(filepath)
        return img.size
    except Exception as e:
        return None, None


def main():
    if len(sys.argv) < 4:
        print("Usage: verify_frames.py <frames_dir> <expected_width> <expected_height> [output_report]")
        sys.exit(1)

    frames_dir = sys.argv[1]
    try:
        expected_width = int(sys.argv[2])
        expected_height = int(sys.argv[3])
    except ValueError:
        print("Error: expected_width and expected_height must be integers")
        sys.exit(1)

    output_report = sys.argv[4] if len(sys.argv) > 4 else os.path.join(frames_dir, "verification_report.txt")

    if not os.path.isdir(frames_dir):
        print(f"Error: {frames_dir} is not a directory")
        sys.exit(1)

    # Collect PNG files sorted by name
    png_files = sorted([f for f in os.listdir(frames_dir) if f.endswith('.png')])

    if not png_files:
        print(f"No PNG files found in {frames_dir}")
        return

    results = []
    hashes = {}  # Track hashes for duplicate detection

    for png_file in png_files:
        filepath = os.path.join(frames_dir, png_file)
        checks = []
        status = "OK"

        # Check 1: File exists and non-trivial size
        try:
            size = get_file_size(filepath)
            if size < 1000:  # Arbitrary threshold for "non-trivial"
                status = "FAIL_SIZE"
                checks.append(f"size_bytes={size}")
            else:
                checks.append(f"size_bytes={size}")
        except Exception as e:
            status = "FAIL_FILE"
            checks.append(f"error={e}")

        # Check 2: Brightness (not blank/black)
        brightness, brightness_ok = check_brightness(filepath)
        if brightness is not None:
            checks.append(f"mean_brightness={brightness}")
            if not brightness_ok:
                status = "FAIL_BRIGHTNESS"

        # Check 3: Blur (if OpenCV available)
        blur_var, blur_ok = check_blur(filepath)
        if blur_var is not None:
            checks.append(f"laplacian_var={blur_var:.1f}")
            if not blur_ok and status == "OK":
                status = "WARN_BLUR"

        # Check 4: Resolution
        width, height = get_resolution(filepath)
        if width is not None and height is not None:
            checks.append(f"resolution={width}x{height}")
            if (width, height) != (expected_width, expected_height) and status == "OK":
                status = "FAIL_RESOLUTION"

        # Check 5: Duplicates (via perceptual hash)
        phash_val = get_perceptual_hash(filepath)
        if phash_val is not None:
            if phash_val in hashes:
                status = "WARN_DUPLICATE"
                checks.append(f"duplicate_of={hashes[phash_val]}")
            else:
                hashes[phash_val] = png_file

        # Format result line
        check_str = " | ".join(checks) if checks else "(no checks run)"
        result_line = f"{png_file} | {status} | {check_str}"
        results.append(result_line)

    # Write report
    with open(output_report, 'w') as f:
        for line in results:
            f.write(line + "\n")

    print(f"Verification report written to {output_report}")
    print("\nSummary:")
    for line in results:
        print(line)


if __name__ == "__main__":
    main()
