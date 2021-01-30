## Summary

Training environment for learning how to work with puppet.



### v0.02 r10k setup and linking to remote github repo

Updated provision.sh shell script

```
  # v0.02 r10k setup and linking to remote github repo

  echo '*** r10k setup and linking to remote repo https://github.com/dgapitts/puppet-control-repo.git'
  mkdir /etc/puppetlabs/r10k
  cat /vagrant/r10k.yaml > /etc/puppetlabs/r10k/r10k.yaml
  cat /etc/puppetlabs/r10k/r10k.yaml
  echo '*** exec r10k deploy environment -p'
  r10k deploy environment -p
  echo '*** show code deployed i.e. initial README.md file'
  cat /etc/puppetlabs/code/environments/production/README.md
  echo '*** show /etc/puppetlabs/code/environments/production/.git/config ' 
  cat /etc/puppetlabs/code/environments/production/.git/config 
```

For more details please see [build_logs/v0.02_r10k_setup_linking_remote_github_repo.log](build_logs/v0.02_r10k_setup_linking_remote_github_repo.log)



## v0.01 initial setup of puppetmaster server (with r10k gem/module) by provision.sh


A few points to highlight
* My ubuntu dev environment (only running VS Code and the odd browser session) has 16G of RAM and given the master puppet java process needs 512M (i.e. 0.5G), so I've setup the VM with 2G i.e. still leaving 14G for the host environment. However 1G should be enough if you are running on a busier dev environment (e.g. my MacAir laptop only has 4Gb). 
* The provision.sh automates the basic setup, I've documented the main customizations below


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
