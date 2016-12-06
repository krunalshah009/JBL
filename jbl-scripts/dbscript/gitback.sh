gitlab-rake gitlab:backup:create
cd /var/opt/gitlab/backups
s3cmd put *gitlab_backup.tar s3://jbl-git-svn-backup/jbl-git/
rm *gitlab_backup.tar 
