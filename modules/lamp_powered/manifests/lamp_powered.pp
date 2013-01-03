
## Working shell environment

class lamp_powered::params()
{
	include offirmo_ubuntu::params

	if ($cpp_working_dir)
	{ $working_dir = $cpp_working_dir }
	else
	{ $working_dir = "$offirmo_ubuntu::params::root_working_dir/www" }
	
	if ($cpp_owner)
	{ $owner = $cpp_owner }
	else
	{ $owner = "$offirmo_ubuntu::params::owner" }
}

# Ensure that the c++ dev tools are present.

class lamp_powered::common($mysql_root_password)
{
	require lamp_powered::params

	## packages
	class
	{
		## Full LAMP stack
		'zend_server_ce_powered':
			;
		## MySQL is already here (from zend)
		## we only want a custom password
		'mysql_powered::server':
			root_password => $mysql_root_password,
			;
	}

	## now serving dirs
	file
	{
		$lamp_powered::params::working_dir:
			ensure => directory,
			owner  => $lamp_powered::params::owner,
			;
	}
}


class lamp_powered::dev($mysql_root_password)
{
	class
	{
		'lamp_powered::common':
			mysql_root_password => $mysql_root_password,
			;
	}

	## TODO add dev tools
	class
	{
		'zend_server_ce_powered::phpmyadmin::with-extended-session-time':
			;
	}
	
} # class lamp_powered::development


class lamp_powered($mysql_root_password)
{
	class
	{
		'lamp_powered::common':
			mysql_root_password => $mysql_root_password,
			;
	}
} # class lamp_powered
