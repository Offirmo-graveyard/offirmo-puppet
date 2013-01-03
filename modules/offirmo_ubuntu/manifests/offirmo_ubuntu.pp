
# My classic ubuntu machine, featuring a few useful packages and tools.

class offirmo_ubuntu::params()
{
	if ($offirmo_root_working_dir)
	{ $root_working_dir = $offirmo_root_working_dir }
	else
	{ $root_working_dir = '/work' }

	if ($offirmo_owner)
	{ $owner = $offirmo_owner }
	else
	{ $owner = 'offirmo' }

	$misc_working_dir = "$root_working_dir/misc"
	## user-related files
	$home_working_dir = "$root_working_dir/home"
	## thi one will be added to the path
	$home_bin_dir = "$home_working_dir/bin"
}

class offirmo_ubuntu()
{
	include offirmo_ubuntu::params

	# First, we check if this class is really applied to a compatible system :
	if $operatingsystem != 'Ubuntu'
	{
		err("It looks like this sytem is not a Ubuntu ($operatingsystem). This class is for ubuntu systems only.")
	}
	else
	{
		# Canonical 'force' the installation of their paying remote package manager.
		# It's only useful when we have a lot of machines.
		# Otherwise, it uselessly stays in memory and opens connections.
		# We don't need it.
		package { 'landscape-client': 
			ensure => purged # yes, purged !
		}
		
		### Useful classes
		class
		{
			'ssh_powered':
				;
			'ntp_powered':
				;
		}
		
		# Useful packages
		package
		{
			# manual
			'man':
				ensure => latest; # this package is not critical, we can use 'latest'
			# A useful resource monitoring tool.
			# Just run it to test it.
			'dstat':
				ensure => latest; # this package is not critical, we can use 'latest'
			# A useful resource monitoring tool. (better than 'top')
			# Just run it to test it.
			'htop':
				ensure => latest; # this package is not critical, we can use 'latest'
			# useful for misc operations. Also useful for some wordpress plugins
			'zip':
				ensure => latest; # this package is not critical, we can use 'latest'
			# useful
			#'locate':
			#	ensure => latest; # this package is not critical, we can use 'latest'
		} # packages
		
		## dirs
		file
		{
			## a root dir where we'll put our work data.
			## The idea is to never work from somewhere else,
			## so we can share it via samba.
			'offirmo-root-working-dir':
				path   => "$offirmo_ubuntu::params::root_working_dir",
				ensure => directory,
				owner  => $offirmo_ubuntu::params::owner,
				;
			## subdirs
			'offirmo-misc-working-dir':
				path   => "$offirmo_ubuntu::params::misc_working_dir",
				ensure => directory,
				owner  => $offirmo_ubuntu::params::owner,
				;
			'offirmo-home-working-dir':
				path   => "$offirmo_ubuntu::params::home_working_dir",
				ensure => directory,
				owner  => $offirmo_ubuntu::params::owner,
				;
			'offirmo-home-bin-dir':
				path   => "$offirmo_ubuntu::params::home_bin_dir",
				ensure => directory,
				owner  => $offirmo_ubuntu::params::owner,
				;
		}

		# alternative, backup admin in case we mess up with the default one
		# (yes, I did it once and lost admin access on my own machine)
		user
		{
			'altadmin':
				shell      => '/bin/bash',
				groups     => ['adm', 'dialout', 'plugdev'], # 'admin', 'cdrom','rvm','lpadmin','sambashare'
				# adm : le fait d'appartenir au groupe adm donne certains privilèges comme par exemple pouvoir accéder aux fichiers log du système ce qu'un utilisateur normal ne peut pas faire. 
				# dialout : The dialout group is used to control access to dialout scripts which connect to ISPs, etc. If you're using ppp, dip or similar services you'll need to be a member of the dialout group. (Or root!)
				# The plugdev group is normally assigned to filesystems contained on removable media. I think by default you should be a member of this group. If not you should add yourself to the plugdev group.
				# other groups : could add later since it's admin
				comment    => "Backup admin,,,",
				managehome => true,
				ensure     => present,
				# no password : will have to be activated by the primary admin
				;
		}
		puppet_powered::human_supervision_needed_class
		{
			"activate-altadmin-user":
				text => "
I can't activate the altadmin user
because you need to manually adjust security for it.
To adjust security :
	sudo visudo
and adjust the last lines.
To set a password : (not always required depending on your config and what you set in the previous file)
	sudo passwd altadmin
",
				;
		}

		## if it is an AWS instance, do more stuff
		# First, we check if this class is really applied to a compatible system :
		if $ec2_public_hostname == ""
		{
			## this is not an AWS instance, do nothing
		}
		else
		{
			# we finish the "altadmin" alternate admin account
			#user 'altadmin':
			$alt_admin_name    = 'altadmin'
			$alt_admin_home    = "/home/$alt_admin_name"
			$alt_admin_ssh_dir = "$alt_admin_home/.ssh"
			
			# ensure .ssh dir exists
			file
			{
				"$alt_admin_ssh_dir":
					require => [ User[ "$alt_admin_name" ] ],
					ensure  => directory,
					owner   => "$alt_admin_name",
					group   => "$alt_admin_name",
					mode    => '700',
					recurse => true,
					;
			}
			
			# copy login key from ref admin
			$ref_admin_name = 'ubuntu'
			$cred_ssh_file  = 'authorized_keys'
			exec
			{
				"altadmin login credentials":
					unless  => "test -f $alt_admin_ssh_dir/$cred_ssh_file", # any file supposed to be here if wp is correctly installed
					command => "cp /home/$ref_admin_name/.ssh/$cred_ssh_file $alt_admin_ssh_dir/$cred_ssh_file; chown $alt_admin_name:$alt_admin_name $alt_admin_ssh_dir/$cred_ssh_file",
					path    => "/bin:/usr/bin",
					require => [ User[ "$alt_admin_name" ], File[ "$alt_admin_ssh_dir" ] ],
					;
			}
		} # check if AWS instance
	} # check if Ubuntu
}


		'git_powered':
			;

			