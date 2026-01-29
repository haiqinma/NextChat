#!/usr/bin/env bash
# this script is used to check code status and generate new package if necessary

set -e
set -u
set -o pipefail

script_dir=$(cd "$(dirname "$0")" || exit;pwd)
work_dir=$(cd "${script_dir}"/.. || exit 1; pwd)
service_name=$(basename "$work_dir")

LOGFILE_PATH="/opt/logs"
LOGFILE_NAME="14-code-status-${service_name}.log"
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

pull_latest_code() {
  local branch_name=$1
  git -C "$work_dir" reset --hard HEAD
  git -C "$work_dir" checkout "$branch_name"
  git -C "$work_dir" pull origin "$branch_name" || { exit 1; }
}

index=1
echo -e "\nstep $index -- This is the begining of check code for ${service_name} [$(date)] " | tee -a "$LOGFILE"
echo -e "Using code path: $work_dir" | tee -a "$LOGFILE"
pull_latest_code main || { echo -e "ERROR! pull code failed" | tee -a "$LOGFILE"; exit 1; }

current_status="/tmp/current_status_${service_name}"
record_version_information "$current_status"


index=$((index+1))
echo -e "\nstep $index -- check wether need to generate package" | tee -a "$LOGFILE"
flag_compile=false
PACKAGE_DIR="/opt/package"
mkdir -p "${PACKAGE_DIR}"
file_package=$(ls -t "${PACKAGE_DIR}"/"${service_name}"-*.tar.gz 2>/dev/null | head -n 1 || true)
echo -e "find package file: ${file_package}" | tee -a "$LOGFILE"
if [[ -z "$file_package" ]]; then
	echo -e "there is no  ${service_name} tar.gz file under ${PACKAGE_DIR}" | tee -a "$LOGFILE"
	flag_compile="true"
else
	dir_package="${PACKAGE_DIR}/${service_name}"
	echo -e "find package directory: ${dir_package}" | tee -a "$LOGFILE"
	if [[ ! -d "$dir_package" ]]; then
		filename=$(basename "$file_package")
		temp=${filename#${service_name}-}
		package_version=${temp%.tar.gz}
		echo -e "untar package and get package version is:$package_version" | tee -a "$LOGFILE"
		tar -zxf "$file_package" -C "$PACKAGE_DIR"
		mv "${PACKAGE_DIR}/${service_name}-${package_version}" "$dir_package"
	fi

	package_version_info=$(ls -t "${dir_package}"/version_information_* 2>/dev/null | head -n 1 || true)
	echo -e "get package version information as: ${package_version_info}" | tee -a "$LOGFILE"
	if [[ -f "$package_version_info" ]]; then
		if diff "$package_version_info" "$current_status" > /dev/null; then
			echo -e "there is no update compared with current package"  | tee -a "$LOGFILE"
			flag_compile="false"
		else
			echo -e "there is code update compared with current package"  | tee -a "$LOGFILE"
			flag_compile="true"
		fi
	else
		echo -e "It seems the package is broken as there is no version information" | tee -a "$LOGFILE"
		flag_compile="true"
	fi

	if [[ "$flag_compile" = "true" ]];then
		rm -f "$file_package"
		rm -rf "$dir_package"
	fi
fi

if [[ "$flag_compile" = "false" ]];then
	echo -e "there is no code update compared with current package. operation Finished ==== $(date) ====" | tee -a "$LOGFILE"
	exit 0
fi


index=$((index+1))
echo -e "\nstep $index -- compile ${service_name} package" | tee -a "$LOGFILE"
pushd "$work_dir" > /dev/null
if command -v yarn >/dev/null 2>&1; then
	yarn install
	yarn build
else
	echo -e "ERROR! yarn is not installed" | tee -a "$LOGFILE"
	exit 1
fi
bash script/package.sh > /dev/null 2>&1
popd > /dev/null


index=$((index+1))
echo -e "\nstep $index -- copy ${service_name} package to ${PACKAGE_DIR}"  | tee -a "$LOGFILE"
compiled_package=$(ls -t "$work_dir"/output/"${service_name}"-*.tar.gz 2>/dev/null | head -n 1 || true)
echo -e "get compiled package: $compiled_package"  | tee -a "$LOGFILE"
if [ -f "$compiled_package" ]; then
	cp -a "$compiled_package" "${PACKAGE_DIR}"
	pushd "$PACKAGE_DIR" > /dev/null
	filename=$(ls -t "${service_name}"-*.tar.gz 2>/dev/null | head -n 1 || true)
	temp=${filename#${service_name}-}
	package_version=${temp%.tar.gz}
	echo -e "get generated package version is:$package_version" | tee -a "$LOGFILE"
	test -d "${service_name}" && rm -rf "${service_name}"
	tar -zxf "${service_name}-${package_version}.tar.gz"
	mv "${service_name}-${package_version}" "${service_name}"
	popd > /dev/null
else
	echo -e "ERROR! There is no package generated." | tee -a "$LOGFILE"
	exit 1
fi


echo -e "\nThis is the end of check ${service_name} code status. ====$(date)====" | tee -a "$LOGFILE"
