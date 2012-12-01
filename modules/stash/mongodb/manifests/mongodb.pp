


class mongodb::params
{
	$config_file = '/etc/mongodb.conf'
}

class mongodb::common
{
	# nothing for now
}

class mongodb::server($password)
{
	include mongodb::params
	require mongodb::common
	
	package
	{
		'mongodb':
			ensure  => latest;
	}
	
	file
	{
		$mongodb::params::config_file:
			ensure => present,
			;
	}
	
	# We want to make sure that the service is running.
	service
	{
		'mongodb':
			ensure     => running,
			hasstatus  => true,
			hasrestart => true,
			require    => Package['mongodb'],
			subscribe  => File[$mongodb::params::config_file],
	}
} # class mongodb::server

class mongodb::client
{
	include mongodb::params
	require mongodb::common
	
	# TODO
	
} # class mongodb::client

class mongodb::server::database($name)
{
	# TODO
	
} # class mongodb::server::database


class mongodb::dev::with_phpmoadmin
{
	include apache2_powered::params
	require apache2_powered
	
	file
	{
		"${apache2_powered::params::dir_serv_default}/moadmin.php":
			source => 'puppet:///modules/mongodb/moadmin.php',
	}
	
} # class mongodb::dev::with_phpmoadmin
