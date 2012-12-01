
# My classic ubuntu machine, featuring a few useful packages and tools.

class offirmo_ubuntu
{
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
		include ssh_powered # SSH is a must-have
		include ntp_powered # very useful
		
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
		
		# alternative admin
		user
		{
			'altadmin':
				shell      => '/bin/bash',
				groups     => ['adm', 'dialout', 'admin', 'plugdev'], # 'cdrom','rvm','lpadmin','sambashare'
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
		puppet::human_supervision_needed_class
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
		
	} # check if Ubuntu
}
