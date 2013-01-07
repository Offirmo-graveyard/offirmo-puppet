

# TODO : autodetect type according to rvm name
class rvm_powered::ruby($user, $type = 'mri', $version = '1.9.3')
{
	# no rvm_powered dependency, but the called classes will have them
	
	case $type
	{
		'mri':
		{
			rvm_powered::ruby::mri
			{
				"rvm-ruby-${type}-$version":
					user    => $user,
					version => $version;
			}
		} # type = mri
		default:
		{
			err("I cannot recognize this ruby type : $type, please investigate.")
		} # unknown type
	} # ruby type
	
}


# a defined ressource for a ruby mri
define rvm_powered::ruby::mri($user, $version = '1.9.3', $set_default = 'yes')
{
	require rvm_powered # this class makes no sense if RVM is not already installed
	require rvm_powered::ruby::mri_common_assets
	
	rvm_powered::exec
	{
		"rvm-install-ruby-mri-$version":
			user => $user,
			cmd  => 'install',
			arg  => $version,
			timeout  => 0,
			require_ => Package[ 'bison', 'autoconf' ],
			## it's ok, existing ruby is not reinstalled
			#unless_  => "su --login $user /usr/local/rvm/bin/rvm list | grep \"$version\"",
			;
	}
	
	if $set_default == 'yes'
	{
		# set this ruby as the default one (for new shells)
		rvm_powered::exec
		{
			"rvm-install-set-ruby-mri-default-to-$version":
				user => $user,
				cmd  => 'alias',
				arg  => "create default ruby-$version", # command was given by cmd-line rvm itself
				# only if not already default
				#unless_  => "sudo /usr/local/rvm/bin/rvm list default | grep \"$ruby_rvm_name\"";
				;
		}
	}
}


class rvm_powered::ruby::mri_common_assets
{
	# When we type "rvm requirements",
	# it lists a lot of packages that are supposed to be required.
	# This list is currently being reviewed.
	# Some are required at execution, not at installation

	require 'with_tool::build-essential'

	# zlib1g zlib1g-dev libc6-dev ncurses-dev => useful ?
	# libsqlite3-dev sqlite3    => no, we don't plan to use sqlite3 for now
	# subversion (for ruby head) => not really needed
	# pkg-config -> ?
	package
	{
		[ 'libreadline6', 'libreadline6-dev' ]: # this one is *absolutely* useful for executing irb (interactive ruby)
			ensure => present;
		[ 'bison', 'autoconf', 'automake' ]: # those one are needed at last to install the 'head' version.
			ensure => present;
		[ 'openssl', 'libssl-dev', 'libtool', 'libyaml-dev', 'libxml2-dev', 'libxslt-dev' ]: # don't know but look useful
			ensure => present;
	}
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

