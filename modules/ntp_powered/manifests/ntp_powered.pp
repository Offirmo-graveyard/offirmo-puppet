
# NTP is great.
# It will automatically set the time on our server.
# It's important for a lot of operations.
			
class ntp_powered
{
	# the standard trifecta
	
	package
	{
		'ntp':
			ensure => latest; # this package is not critical, we can use 'latest'
	}
	
	file
	{
		'ntp-config-file':
			path    => '/etc/ntp.conf',
			require => Package['ntp'];
	} # file
	
	service
	{
		'ntp':
			ensure     => running,
			enable     => true,
			subscribe  => File['ntp-config-file'],
			hasrestart => true,
	} # service
	
} # class ntp_powered
