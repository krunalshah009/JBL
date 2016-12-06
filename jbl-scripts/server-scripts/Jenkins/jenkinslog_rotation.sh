LOG_HOME_JENKINS=/var/log/jenkins/
cd $LOG_HOME_JENKINS
tar -cvzf jenkins.log-$(date +%Y-%m-%d).tar.gz jenkins.log
rm -rf jenkins.log ;touch jenkins.log && chown jenkins:jenkins -R jenkins.log
/etc/init.d/jenkins restart
cat jenkins.log |sendmail balasaheb.gopale@justbuylive.com || exit 1
