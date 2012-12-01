

# TODO : autodetect type according to rvm name
class rvm_powered::ruby::environment($type = 'mri', $ruby_rvm_name = 'ruby-1.9.2-head')
{
	# no rvm_powered dependency, but the called classes will have them
	
	case $type
	{
		'mri':
		{
			rvm_powered::ruby::mri
			{
				"rvm-ruby-$ruby_rvm_name":
					ruby_rvm_name => $ruby_rvm_name;
			}
		} # type = mri
		default:
		{
			err("I cannot recognize this ruby type : $type, please investigate.")
		} # unknown type
	} # ruby type
	
	# this config attemps to speed up things by disabling the download of the gems doc
	file
	{
		'/etc/gemrc':
			source => 'puppet:///modules/rvm_powered/gemrc';
	}
	
}


class rvm_powered::ruby::mri_common_assets
{
	# When we type "rvm notes",
	# it lists a lot of packages that are supposed to be required.
	# This list is currently being reviewed.
	
	# They are required at execution, not at installation, so we don't have to declare the requirement to puppet.
	# libreadline6   => useful ?
	# zlib1g zlib1g-dev  libc6-dev ncurses-dev => useful ?
	# libsqlite3-0 libsqlite3-dev sqlite3    => no, we don't plan to use sqlite3 for now
	# subversion (for ruby head) => not really needed
	package
	{
		[ 'libreadline6-dev' ]: # this one is *absolutely* useful for executing irb (interactive ruby)
			ensure => present;
		[ 'bison', 'autoconf' ]: # those one are needed at last to install the 'head' version.
			ensure => present;
		[ 'openssl', 'libssl-dev', 'libyaml-dev', 'libxml2-dev', 'libxslt-dev' ]: # don't know but look useful
			ensure => present;
	}
}

# a defined ressource for a ruby mri
define rvm_powered::ruby::mri($ruby_rvm_name = 'ruby-1.9.2', $default = 'yes')
{
	require rvm_powered # this class makes no sense if RVM is not already installed
	require rvm_powered::ruby::mri_common_assets
	
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
		"rvm-install-$ruby_rvm_name":
			require => Package[ 'bison', 'autoconf' ],
			command => "sudo /usr/local/rvm/bin/rvm install $ruby_rvm_name",
			# install only if not already here
			unless  => "sudo /usr/local/rvm/bin/rvm list | grep \"$ruby_rvm_name\"",
			timeout => 3600; # in s. Very important. Ruby will be compiled and this may take a very long time (> 30 min).
			                 # By default, puppet don't wait this long and consider it a failure. So we give more time.
	}
	
	if $default == 'yes'
	{
		# set this ruby as the default one
		exec
		{
			"rvm-set-$ruby_rvm_name-as-default":
				command => "sudo /usr/local/rvm/bin/rvm --default use $ruby_rvm_name",
				require => Exec["rvm-install-$ruby_rvm_name"],
				# only if not already default
				unless  => "sudo /usr/local/rvm/bin/rvm list default | grep \"$ruby_rvm_name\"";
		}
	}
	
}