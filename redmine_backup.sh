#/bin/bash

output_file=""
path=""
nfs="false"
nfs_url="nfs.domain.com:/dir"
nfs_mount_point="/mnt"
nfs_dir="redmine"

function show_help()
{
  echo "-p Store backup in nfs."
  echo "-h Show this help."
}

function mount_nfs()
{
  [ -d $nfs_mount_point ] || mkdir $nfs_mount_point
  mount | grep "$nfs_url" > /dev/null
  if [ $? -eq 0 ];then
    echo "$nfs_mount_point is already mounted."
  else
    mount -t nfs $nfs_url $nfs_mount_point
    if [ $? -eq 0 ]; then
      echo "$nfs_mount_point mounted correctly..."
    else
      echo "Problem mounting $nfs_mount_point. Exiting..."
      exit 1
    fi
  fi
}

while getopts ":n" opt; do
  case $opt in
    n)
      nfs="true"
      ;;
    h)
      show_help
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      show_help
      exit 1
      ;;
  esac
done

if [ "x$nfs" = "xtrue" ];then
  mount_nfs
fi

