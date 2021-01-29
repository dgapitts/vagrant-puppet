## Summary

Training environment for learning how to work with puppet.

## v0.01 initial setup of puppetmaster server 


A few points to highlight
* My ubuntu laptop has 16G of RAM and given the master puppet java process needs 512M (i.e. 05G), I've setup the VM with 2G
* The provision.sh automates the basic setup


As I've set my VM name to puppetmaster

```
  config.vm.hostname = "puppetmaster"
```

I hit a few issues when starting the agent

> Warning: Server hostname 'master.puppet.vm' did not match server certificate; expected one of puppetmaster, DNS:puppet, DNS:puppetmaste

* https://stackoverflow.com/questions/58003882/puppet-master-agent-configuration
* https://ask.puppet.com/question/17689/server-hostname-did-not-match-server-certificate/

and the solution was to update the puppet.conf to match the hostname

```
[~/projects/vagrant-puppet] # tail -2 puppet.conf 
[agent]
server = puppetmaster
```

Here is the initial provision.sh.

```
[~/projects/vagrant-puppet] # cat provision.sh 
#! /bin/bash
if [ ! -f /home/vagrant/already-installed-flag ]
then
  echo "ADD EXTRA ALIAS VIA .bashrc"
  cat /vagrant/bashrc.append.txt >> /home/vagrant/.bash_profile
  cat /vagrant/bashrc.append.txt >> /root/.bashrc
  #echo "GENERAL YUM UPDATE"
  #yum -y update
  yum  -y install unzip curl wget git


  # prevent vagrant user ssh warning "setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory"
  cat /vagrant/environment >> /etc/environment 



  # Install the repository RPM
  rpm -Uvh https://yum.puppet.com/puppet6-release-el-7.noarch.rpm
  yum install -y puppetserver

  echo '*** update sysconfig/puppetserver reduce java memory from default 2G to 0.5G (512mb)'
  cp -p /etc/sysconfig/puppetserver /etc/sysconfig/puppetserver.`date '+%Y%m%d-%H%M'`.bak
  cat /vagrant/puppetserver > /etc/sysconfig/puppetserver

  echo '*** update puppet.conf set server = puppetmaster (to match config.vm.hostname=puppetmaster)'
  cp -p /etc/puppetlabs/puppet/puppet.conf /etc/puppetlabs/puppet/puppet.conf.`date '+%Y%m%d-%H%M'`.bak
  cat /vagrant/puppet.conf > /etc/puppetlabs/puppet/puppet.conf

  echo '*** update $PATH to $PATH:/opt/puppetlabs/puppet/bin:$HOME/bin'
  cp -p ~/.bash_profile ~/.bash_profile.`date '+%Y%m%d-%H%M'`.bak
  cat /vagrant/bash_profile > ~/.bash_profile
  source ~/.bash_profile

  systemctl start puppetserver
  systemctl enable puppetserver
  echo '*** systemctl status puppetserver'
  systemctl status puppetserver

  echo '*** free -m'
  free -m 
  echo '*** uptime'
  uptime

  # initial cron
  crontab /vagrant/root_cronjob_monitoring_sysstat.txt


  echo '*** gem install r10k (R10k provides a general purpose toolset for deploying Puppet environments and modules.)'
  gem install r10k
  echo '*** simple test via: puppet agent -t'
  puppet agent -t


else
  echo "already installed flag set : /home/vagrant/already-installed-flag"
fi
```

For more details please see [build_logs/v0.01_initial_provision.sh_setup.log](build_logs/v0.01_initial_provision.sh_setup.log)
