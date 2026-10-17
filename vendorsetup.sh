#!/bin/bash
#
# This file is part of the OrangeFox Recovery Project
# Copyright (C) 2020-2026 The OrangeFox Recovery Project
#
# OrangeFox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# OrangeFox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# This software is released under GPL version 3 or any later version.
# See <http://www.gnu.org/licenses/>.
#
# Please maintain this if you use this script or any part of it.
#

device_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
workspace_root="$(cd "${device_dir}/../../.." && pwd)"
patch_files=(
	"${device_dir}/patches/01-patch-vibration.patch"
	"${device_dir}/patches/02-patch-health-hal.patch"
	"${device_dir}/patches/03-patch-flashlight.patch"
)

export ALLOW_MISSING_DEPENDENCIES=true

export FOX_BUILD_DEVICE=X6728
export FOX_VIRTUAL_AB_DEVICE=1
export FOX_VENDOR_BOOT_RECOVERY=1
export FOX_INSTALLER_VENDOR_BOOT_RAMDISK_INSTALL=1
export FOX_USE_ZSTD_BINARY=1
export FOX_USE_DMSETUP=1

if ! command -v patch >/dev/null 2>&1; then
	echo "[X6728] Missing required command: patch"
else
	for patch_file in "${patch_files[@]}"; do
		patch_name="$(basename "${patch_file}")"
		if [ ! -f "${patch_file}" ]; then
			echo "[X6728] Missing patch: ${patch_file}"
		elif (
			cd "${workspace_root}" &&
			patch -p1 -N --dry-run --silent < "${patch_file}" >/dev/null 2>&1
		); then
			if (
				cd "${workspace_root}" &&
				patch -p1 -N --silent < "${patch_file}" >/dev/null 2>&1
			); then
				echo "[X6728] Applied patch: ${patch_name}"
			else
				echo "[X6728] Failed to apply patch: ${patch_name}"
			fi
		else
			echo "[X6728] Patch already applied or not applicable: ${patch_name}"
		fi
	done
fi

unset device_dir workspace_root patch_files patch_file patch_name
