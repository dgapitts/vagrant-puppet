# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:/opt/puppetlabs/puppet/bin
PATH=$PATH:$HOME/bin

export PATH
