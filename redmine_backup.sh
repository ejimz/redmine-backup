#/bin/bash

nfs_url="nfs.domain.com:/nfs"
nfs_mount_point="/mnt/"
backup_dir="/mnt/redmine"

mysql_db="db"
mysql_user="user"
mysql_password="pw"
mysql_host="localhost"
mysql_port="3306"

app_dir="/var/redmine/current"

rotation="true"
rotation_days=10

cur_date=$(date +%d%m%y)
cur_timestamp=$(date +%s)

func_show_help()
{
  echo "-p Store backup in nfs."
  echo "-h Show this help."
}

func_mount_nfs()
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

func_check_backup_dir()
{
  [ -d $backup_dir ] || mkdir -p $backup_dir
  if [ $? -ne 0 ];then
    echo "Problem checking backup dir. Exiting..."
    exit 1
  fi
  mkdir -p $backup_dir/$cur_date
}

func_check_rotation()
{
  if [ "x$backup_dir" != "x" ] ;then
    find $backup_dir -type d -mtime +$rotation_days | xargs rm -rf
  fi
}

func_get_sql()
{
  mysqldump --opt --host=$mysql_host --port=$mysql_port --password=$mysql_password --user=$mysql_user $mysql_db > $backup_dir/$cur_date/$cur_timestamp.sql
  if [ $? -ne 0 ];then
    echo "Problem getting mysql dump. Exiting..."
    exit 1
  else
    echo "Mysql dump finished correctly."
  fi
}

func_get_app_dir()
{
  cp -r $app_dir/ $backup_dir/$cur_date/$cur_timestamp > /dev/null
  if [ $? -ne 0 ];then  
    echo "Problem getting app dir. Exiting..."
    exit 1
  else
    echo "App copied correctly."
  fi
}

while getopts ":n" opt; do
  case $opt in
    n)
      nfs="true"
      ;;
    h)
      func_show_help
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      func_show_help
      exit 1
      ;;
  esac
done

if [ "x$nfs" = "xtrue" ];then
  func_mount_nfs
fi

func_check_backup_dir
func_get_sql
func_get_app_dir
[ "x$rotation" == "xtrue" ] && func_check_rotation

