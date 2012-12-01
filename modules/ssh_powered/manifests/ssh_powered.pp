
# Ensure that the ssh tool is present.

class ssh_powered
{
	package
	{
		'ssh':
			ensure => latest; # this package is very well tested and security-critical, we *must* use 'latest'
	} # package
	
	file
	{
		'ssh-config-file':
			path    => '/etc/ssh/sshd_config',
			require => Package['ssh'];
	} # file
	
	service
	{
		'ssh':
			ensure     => running,
			enable     => true,
			subscribe  => File['ssh-config-file'],
			hasrestart => true,
	} # service
	
} # class ssh
