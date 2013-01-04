
# Ensure that Ruby Version Manager is installed.
# RVM is tricky to install and maintain.

class rvm_powered($version = 'stable', $security = 'yes')
{
	
	# Preparation : we set the pathes for all 'exec' resources in this scope.
	Exec {
		path => [
				'/usr/local/rvm/bin', ## of course, it is not present at start
				'/usr/local/bin',
				'/opt/local/bin',
				'/usr/bin',
				'/usr/sbin',
				'/bin',
				'/sbin' ],
		logoutput => true,
	} # Exec
	
	
	####### prerequisites
	# https://rvm.beginrescueend.com/rvm/prerequisites/
	# http://doc.ubuntu-fr.org/rubyonrails#installation_de_ruby
	require git_powered # RVM needs git to install
	require with_tool::bash
	require with_tool::curl
	require with_tool::patch
	require with_tool::build-essential
	# zlib1g-dev libssl-dev libreadline6-dev
	
	
	####### Installation
	# RVM gives a "magic" command to install itself, cf. https://rvm.beginrescueend.com/rvm/install/
	# We need more control, so we keep the "magic command" but break it into separate steps.
	# Last checked 2011/04/18
	
	### Installation preparation
	# We need the installer script.
	# RVM suggest to download it and then sudo exec.
	# It's ok when done manually because we can review the file.
	# But when automating it with puppet, we cannot allow that !
	# Or else, a hacker replacing the installer file
	# can root-run any command he wants on our server !
	# We'll provide our own, checked copy of the installer.
	# This copy is supposed to have been downloaded manually and then checked.
	$rvm_installer_file = '/tmp/rvm_installer'
	if $security == 'no-and-I-really-understand-what-I-do'
	{
		# OK, download the installer from RVM.
		# security issues...
		exec
		{
			'rvm-get-installer':
				# the recommended install command : absolute latest, system wide
				command => "sudo curl -L https://get.rvm.io -o $rvm_installer_file";
		} # exec
		# possible race condition ? File safe ?
		file
		{
			"$rvm_installer_file":
				require => Exec['rvm-get-installer'],
				owner   => root,
				group   => root,
				mode    => 755; # restrictive rights, of course.
		} # file
	}
	else
	{
		# we use our own, (hopefully) checked copy of the installer
		file
		{
			"$rvm_installer_file":
				source  => "puppet:///modules/rvm_powered/rvm-installer",
				replace => true, # yes, download it every time, or else someone may replace it !
				owner   => root,
				group   => root,
				mode    => 755; # restrictive rights, of course.
		} # file
	}
	
	# with specific version (but OK if latest)
	exec
	{
		### Installation (if needed)
		'rvm-install':
			command => "$rvm_installer_file --version $version",
			#creates => ["/usr/local/rvm/bin/rvm", "/usr/local/rvm/VERSION"],
			unless  => $version ? {
						'latest' => "test -x /usr/local/rvm/bin/rvm",
						default  => "grep \"$version\" /usr/local/rvm/VERSION",
					},
			require => [ Package['bash', 'curl', 'patch', 'build-essential', 'git-core'], File["$rvm_installer_file"] ],
			notify  => Exec['rvm-reload'];
	}
	
	if $version == 'latest'
	{
		# automatic update
		exec
		{
			### Update (always)
			'rvm-update':
				command  => 'sudo /usr/local/rvm/bin/rvm get head',
				require  => Exec['rvm-install'],
				schedule => rvm_update_period, # This command is a bit long to execute, so we plan it only once in a while.
				notify   => Exec['rvm-reload'];
		}
		# we define what we mean by 'rvm_update_period'
		schedule
		{
			rvm_update_period:
				period => daily,
				range => '2-4'
		}
	}
	
	exec
	{
		'rvm-reload':
			command     => 'sudo /usr/local/rvm/bin/rvm reload',
			refreshonly => true # only when triggered by someone else (see 'notify')
	}
}



# To use rvm, users need to be declared
class rvm_powered::user($username)
{
	#include rvm_powered  in fact, no dependency.
	
	$user_home = "/home/$username"
	
	## bashrc : since we use system_wide rvm install, users do not need a modification of their bashrc
	
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

