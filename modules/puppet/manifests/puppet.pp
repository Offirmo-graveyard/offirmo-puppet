
# 



# utility class
# used to be able to specifiy a run stage
class with_puppet_apt_repository
{
	apt_powered::ppa_apt_repository
	{
		puppet_backports_ppa_apt_repository:
			ppa    => 'ppa:mathiaz/puppet-backports',
			override_branch => 'lucid', # we have to override this since this ppa has only 'lucid' branch
			;
	}
} # class with_puppet_apt_repository


class puppet::params
{
	$lib_dir     = '/var/lib/puppet'
	$data_dir    = '/etc/puppet'
	
	$config_file = "$data_dir/puppet.conf"
	
	$todo_dir    = "$data_dir/couldnt-do-it"
} # class puppet::params



class puppet::common_assets
{
	include puppet::params
	
	class
	{
		# we use an utility class to be able to specify the stage
		with_puppet_apt_repository:
			stage => apt
	}
	
	package
	{
		'facter':
			ensure  => present; # this package is critical and updates should be supervised. We don't use 'latest'.
		'puppet':
			ensure  => present, # this package is critical and updates should be supervised. We don't use 'latest'.
			require => Package['facter'];
	} # package
	
	file
	{
		# a special directory
		$puppet::params::todo_dir:
			mode     => '754',
			ensure   => directory,
			require  => Package['puppet'];
	} # file
} # class puppet::common_assets


class puppet::server
{
	require puppet::common_assets
	
	# for the mkpasswd tool, used when creating a user with a pre-set password
	if ($::operatingsystem == 'Ubuntu')
	{
		case $::lsbdistcodename
		{
			'lucid':
			{
				package
				{
					'mkpasswd':
						ensure => latest,
						;
				}
			}
			'maverick':
			{
				require with_tool::whois
			}
		}
	}
	
	
	file
	{
		$puppet::params::config_file:
			mode     => '644',
			require  => Package['puppet'];
	} # file
	
	# service
	# {
		# 'puppet':
			# ensure     => running,
			# enable     => true,
			# subscribe  => File[$puppet::params::config_file],
			# hasrestart => true,
	# } # service
}

class puppet::client
{
	require puppet::common_assets
	
}


# A class to give a "todo list" of installation steps that couldn't be automatized.
# It write instructions into a file under a special directory
# WARNING the "name" of the resource is used as a file name. It must be correct.
define puppet::impossible_class($text)
{
	require puppet::common_assets
	
	$filename = "${puppet::params::todo_dir}/todo-${name}.txt"
	
	file
	{
		$filename:
			ensure  => present,
			content => "
This file is to report an installation step that can't be automated (yet)
-------------------------------------------------------------------------
$text
------------
",
			;
	}
}

# the same, with a slightly different semantic
define puppet::human_supervision_needed_class($text)
{
	require puppet::common_assets
	
	$filename = "${puppet::params::todo_dir}/todo-${name}.txt"
	
	file
	{
		$filename:
			ensure  => present,
			content => "
This file is to report an installation step that can't be automated (yet)
because it needs to be reviewed by a human.
-------------------------------------------------------------------------
$text
------------
",
			;
	}
}


