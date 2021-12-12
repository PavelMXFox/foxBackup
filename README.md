# foxBackup

## keys 

-f = full backup (if not = increment)

-q - suppress logs output


## config options

sqldump_prefix="docker exec -t db mysqldump" = prefix for sqldump

sql_list="dbname dbname2 dbname3:table:table" = sql db list or tables list

files_list="/path/to/folder1 /path/to/folder/2:subfolder:file_in_folder:subfodler/subsub" = file list. Each line in separate archive.

prefix='/path_to_temp_folder'; = prefix for compessed and index folders

sshhost='host'; = ssh host to upload (if empty upload is skipped)

sshport=22;

sshuser='login';

sshkey='/path_to_ssh_private_key';

sshpath='/media/hdd2/backup'; = remote path for SCP store

# Check

Run at backup storage, checks expired backups in all forders with prefix backup- in ``prefix`` folder.

All deltas calculated from file names!

## Config

prefix='/mnt/backups'; # Storage prefix

dailySecMax=936000; # DailyDelta in seconds

fullSecMax=29376000; # FullDelta in seconds
