
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


class puppet_powered::params
{
	$lib_dir     = '/var/lib/puppet'
	$data_dir    = '/etc/puppet'
	
	$config_file = "$data_dir/puppet.conf"
	
	$todo_dir    = "$data_dir/couldnt-do-it"


	include offirmo_ubuntu::params

	if ($puppet_working_dir)
	{ $working_dir = $puppet_working_dir }
	else
	{ $working_dir = "$offirmo_ubuntu::params::root_working_dir/puppet" }
	
	if ($puppet_owner)
	{ $owner = $puppet_owner }
	else
	{ $owner = "$offirmo_ubuntu::params::owner" }

} # class puppet_powered::params



class puppet_powered::common_assets
{
	include puppet_powered::params
	
	if ($::operatingsystem == 'Ubuntu')
	{
		# ubuntu 12 has a decent puppet version
		# but earlier versions need backports
		if ($::lsbmajdistrelease < 12)
		{
			class
			{
				# we use an utility class to be able to specify the stage
				with_puppet_apt_repository:
					stage => apt
			}
		}
	}

	package
	{
		'facter':
			ensure  => present; # this package is critical and updates should be supervised. We don't use 'latest'.
		'puppet':
			ensure  => present, # this package is critical and updates should be supervised. We don't use 'latest'.
			require => Package['facter'];
	} # package
	
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
			'precise':
			{
				require with_tool::whois
			}
			## TODO catch-all
		}
	}


	## now dirs
	file
	{
		$puppet_powered::params::working_dir:
			ensure => directory,
			owner  => $puppet_powered::params::owner,
			;
	}

	file
	{
		# a special directory
		$puppet_powered::params::todo_dir:
			mode     => '754',
			ensure   => directory,
			require  => Package['puppet'];
	} # file
} # class puppet_powered::common_assets


## TODO finish
class puppet_powered::server
{
	require puppet_powered::common_assets
	
	file
	{
		$puppet_powered::params::config_file:
			mode     => '644',
			require  => Package['puppet'];
	} # file
	
	# service
	# {
		# 'puppet':
			# ensure     => running,
			# enable     => true,
			# subscribe  => File[$puppet_powered::params::config_file],
			# hasrestart => true,
	# } # service
}

class puppet_powered::client
{
	require puppet_powered::common_assets
}

class puppet_powered::dev
{
	require puppet_powered::common_assets

	## nothing special (for now)
}


# A class to give a "todo list" of installation steps that couldn't be automatized.
# It write instructions into a file under a special directory
# WARNING the "name" of the resource is used as a file name. It must be correct.
define puppet_powered::impossible_class($text)
{
	require puppet_powered::common_assets
	
	$filename = "${puppet_powered::params::todo_dir}/todo-${name}.txt"
	
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
define puppet_powered::human_supervision_needed_class($text)
{
	require puppet_powered::common_assets
	
	$filename = "${puppet_powered::params::todo_dir}/todo-${name}.txt"
	
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
