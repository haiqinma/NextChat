#!/usr/bin/env bash

set -u
set -o pipefail

script_dir=$(cd "$(dirname "$0")" || exit;pwd)
work_dir=$(cd "${script_dir}"/.. || exit 1; pwd)
service_name=$(basename "$work_dir")

LOGFILE_PATH="/opt/logs"
LOGFILE_NAME="04-package-${service_name}.log"
LOGFILE="$LOGFILE_PATH/$LOGFILE_NAME"
if [[ ! -d  "$LOGFILE_PATH" ]]
then
    mkdir -p "$LOGFILE_PATH"
fi

touch "$LOGFILE"

filesize=$(stat -c "%s" "$LOGFILE" )
if [[ "$filesize" -ge 1048576 ]]
then
    echo -e "clear old logs at $(date) to avoid log file too big" > "$LOGFILE"
fi

record_version_information() {
  local record_file=$1
  echo -e "\n========branch information:" | tee "$record_file"
  git -C "$work_dir" branch --show-current | tee -a "$record_file"
  echo -e "\n========commit log information:" >> "$record_file"
  git -C "$work_dir" log -3 | grep -v Author | tee -a "$record_file"
  echo -e "\n====Finished" | tee -a "$record_file"
}

get_version() {
  local version=""
  version=$(node -p "require('${work_dir}/package.json').version" 2>/dev/null || true)
  if [[ -z "$version" || "$version" == "undefined" ]]; then
    version=$(git -C "$work_dir" rev-parse --short HEAD 2>/dev/null || true)
  fi
  if [[ -z "$version" ]]; then
    version=$(date '+%Y%m%d_%H%M%S')
  fi
  echo "$version"
}

index=1
echo -e "step $index -- This is the begining of create package for ${service_name} [$(date)] " | tee -a "$LOGFILE"

version=$(get_version)
if [ -z "${version}" ]; then
  echo -e " ERROR! the version could not be empty! " | tee -a "$LOGFILE"
  exit 3
fi

standalone_dir=${work_dir}/.next/standalone
static_dir=${work_dir}/.next/static
public_dir=${work_dir}/public
output_dir=${work_dir}/output

if [ ! -d "${standalone_dir}" ]; then
  echo -e "please execute 'yarn build' before package! (.next/standalone is missing)" | tee -a "$LOGFILE"
  exit 1
fi
if [ ! -d "${static_dir}" ]; then
  echo -e "please execute 'yarn build' before package! (.next/static is missing)" | tee -a "$LOGFILE"
  exit 1
fi

if [ -d "${output_dir}" ]; then
  rm -rf "${output_dir}"
fi

index=$((index+1))
echo -e "step $index -- prepare package files under directroy: ${output_dir} " | tee -a "$LOGFILE"
package_name="${service_name}"-"${version}"
file_name=$package_name.tar.gz
pkg_dir=${output_dir}/${package_name}
mkdir -p "${pkg_dir}"

index=$((index+1))
echo -e "step $index -- copy necessary file to  ${pkg_dir} " | tee -a "$LOGFILE"
cp -a "${standalone_dir}/." "${pkg_dir}/"
mkdir -p "${pkg_dir}/.next"
cp -a "${static_dir}" "${pkg_dir}/.next/"
if [ -d "${public_dir}" ]; then
  cp -a "${public_dir}" "${pkg_dir}/"
fi
cp -a "${script_dir}" "${pkg_dir}/"
formatted_date=$(date '+%Y%m%d_%H%M%S')
VERSION_FILE="version_information_$formatted_date"
record_version_information "$VERSION_FILE"
mv "$VERSION_FILE" "${pkg_dir}/"

sleep 1
index=$((index+1))
echo -e "step $index -- generate package file. " | tee -a "$LOGFILE"
pushd "${output_dir}" > /dev/null || exit 2
tar -zcf "${file_name}" "${package_name}"
rm -rf "${package_name}"
popd  > /dev/null || exit 2

index=$((index+1))
echo -e "step $index -- package : ${file_name} under [ ${output_dir} ] is ready. [$(date)] " | tee -a "$LOGFILE"
