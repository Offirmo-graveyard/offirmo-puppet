

# To use rvm, users need to have some private files modified
class rvm_powered::user($username)
{
	#include rvm_powered  in fact, no dependency.
	
	$user_home = "/home/$username"
	
	file
	{
		"$user_home/.bash_profile":
			source => "puppet:///modules/rvm_powered/bash_profile",
			owner  => "$username",
			group  => "$username",
			mode   => 644,
	}
	
	# this file attemps to speed up things by disabling the download of the gems doc
	file
	{
		"$user_home/.gemrc":
			source => 'puppet:///modules/rvm_powered/gemrc';
	}
	
	# WARNING
	# This file, when created BEFORE rvm installation,
	# prevent it from installing. So we have to be careful and add a dependency !
	# file
	# {
		# "$user_home/.rvmrc":
			# source  => "puppet:///modules/rvm_powered/rvmrc",
			# owner   => "$username",
			# group   => "$username",
			# mode    => 644,
			# require => Exec['rvm-install']; # very important
	# }

# WARNING:  you have a 'return' statement in your ~/.bashrc
# notice: /Stage[main]/Rvm_powered/Exec[rvm-install]/returns:               This could cause some features of RVM to not work.
# notice: /Stage[main]/Rvm_powered/Exec[rvm-install]/returns:
# notice: /Stage[main]/Rvm_powered/Exec[rvm-install]/returns:
# notice: /Stage[main]/Rvm_powered/Exec[rvm-install]/returns:   This means that if you see something like:
# notice: /Stage[main]/Rvm_powered/Exec[rvm-install]/returns:
# notice: /Stage[main]/Rvm_powered/Exec[rvm-install]/returns:     '[ -z "$PS1" ] && return'
# notice: /Stage[main]/Rvm_powered/Exec[rvm-install]/returns:
# notice: /Stage[main]/Rvm_powered/Exec[rvm-install]/returns:   then you change this line to:
# notice: /Stage[main]/Rvm_powered/Exec[rvm-install]/returns:
# notice: /Stage[main]/Rvm_powered/Exec[rvm-install]/returns:   if [[ -n "$PS1" ]] ; then
# notice: /Stage[main]/Rvm_powered/Exec[rvm-install]/returns:
# notice: /Stage[main]/Rvm_powered/Exec[rvm-install]/returns:     # ... original content that was below the '&& return' line ...
# notice: /Stage[main]/Rvm_powered/Exec[rvm-install]/returns:
# notice: /Stage[main]/Rvm_powered/Exec[rvm-install]/returns:   fi # <= be sure to close the if at the end of the .bashrc.
# notice: /Stage[main]/Rvm_powered/Exec[rvm-install]/returns:
# notice: /Stage[main]/Rvm_powered/Exec[rvm-install]/returns:   # This is a good place to source rvm v v v
# notice: /Stage[main]/Rvm_powered/Exec[rvm-install]/returns:   [[ -s "/usr/local/rvm/scripts/rvm" ]] && source "/usr/local/rvm/scripts/rvm"  # This loads RVM into a shell session.
# notice: /Stage[main]/Rvm_powered/Exec[rvm-install]/returns:
# notice: /Stage[main]/Rvm_powered/Exec[rvm-install]/returns: EOF - This marks the end of the .bashrc file
}

# defined resource to execute rvm commands
define rvm_powered::exec($rvm_env, $command, $unless_ = '')
{
	require rvm_powered # this class makes no sense if RVM is not already installed
	
	exec
	{
		"$name":
			command => "/usr/bin/sudo /usr/local/rvm/bin/rvm $rvm_env $command",
			logoutput => true,
	}
	if $require {	Exec["$name"] { require +> $require } }
	if $unless_ {	Exec["$name"] { unless  +> $unless_ } }
}


define rvm_powered::gemset($ruby_rvm_name, $gemset_name, $default = 'yes')
{
	require rvm_powered::ruby::environment # of course, an environment is mandatory
	
	# First we set the path for all 'exec' resources in this scope
	Exec {
		path => [
				'/usr/local/bin',
				'/opt/local/bin',
				'/usr/bin',
				'/usr/sbin',
				'/bin',
				'/sbin' ],
		logoutput => true,
	} # Exec
	
	exec
	{
		"rvm-create-gemset-$gemset_name":
			command => "sudo /usr/local/rvm/bin/rvm gemset create $gemset_name",
			unless  => "sudo /usr/local/rvm/bin/rvm gemset list | grep \" $gemset_name\\>\"", # spaces before and \> after to minimize misunderstandings
			require => Exec["rvm-install-$ruby_rvm_name"], # seen case where the gemset is created before the ruby install. Should not happen ?
			;
		# set default : not working.
		# "rvm-use-gemset-$gemset_name":
			# command => $default ? {
						# 'no'    => "sudo /usr/local/rvm/bin/rvm gemset use $gemset_name",
						# default => "sudo /usr/local/rvm/bin/rvm gemset use $gemset_name --default",
					# },
			# require => Exec[ "rvm-create-gemset-$gemset_name" ];
	}
	
	# in order to bootstrap app installations, we need at last the "bundler" gem.
	$rvm_env = "$ruby_rvm_name@$gemset_name"
	rvm_powered::exec
	{
		"bundler-gem-install-for-gemset-$gemset_name":
			command => "gem install bundler",
			rvm_env => $rvm_env,
			require => Exec[ "rvm-create-gemset-$gemset_name" ],
			unless_ => "sudo /usr/local/rvm/bin/rvm $rvm_env gem list | grep \"\\<bundler \"",
			;
	}
}
