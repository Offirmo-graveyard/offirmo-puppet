
# Ensure that the igraph graph manipulation library is present.

class mysql_powered::client
{
	package
	{
		"libmysqlclient-dev":
			ensure => latest;
	}
} # class mysql_powered::client



class mysql_powered::server($provider = 'zend', $password)
{
	case $provider
	{
		'zend':
		{
			# require zend_server_ce_powered
			$dep_package = Package['phpmyadmin-zend-server']
		}
		default:
		{
			err("I'm sorry, I can't recognize the MySQL provider '$provider'.")
			$dep_package = Package['mysql-server']
		}
	}
	
	exec
	{
		"Set MySQL server root password": # cf. http://www.cyberciti.biz/faq/mysql-change-root-password/
			require     => $dep_package,
			#refreshonly => true,
			unless      => "mysqladmin -u root -p'$password' status",
			path        => "/bin:/usr/bin",
			command     => "mysqladmin -u root password $password",
	}
	
	# service
	# {
		# "mysqld":
			# ensure          => running,
			# enable          => true,
			# hasrestart      => true,
			# hasstatus       => true,
			# require         => Package['mysql-server'],
	# }
	
} # class mysql_powered::server

define mysql_powered::server::serving_database($root_password, $user = '')
{
	require mysql_powered::server
	
	$dbname = $name
	
	exec
	{
		"create MySQL database $name":
			path     => "/bin:/usr/bin",
			# will throw an error if NOK
			command  => "mysqladmin -u root -p'$root_password' create $name",
			returns  => [0, 1], # OK if failure
			# thank you http://serverfault.com/questions/173978/from-a-shell-script-how-can-i-check-whether-a-mysql-database-exists
			unless   => "test -n \"`mysql --user='root' --password='$root_password' --batch --skip-column-names -e \"SHOW DATABASES LIKE '$name'\"`\"", # rem : -n = "is non zero"
			notify   => $user ? {
						'' => undef,
						default => Exec["give full rights on $dbname to $user"],
				},
			;
	}
	
	if $user
	{
		exec
		{
			"give full rights on $dbname to $user": # http://dev.mysql.com/doc/refman/5.5/en/grant.html
				#require     => Exec["create mysql user $user", "create MySQL database $name"],
				subscribe   => Exec[ "create MySQL database $name"],
				refreshonly => true,
				path        => "/bin:/usr/bin",
				command     => "echo \"GRANT ALL ON $dbname.* TO '$user'@'localhost'\" | mysql --user='root' --password='$root_password'",
				# notify => GRANT GRANT_OPTION ON $dbname.* TO '$user'@'localhost' => no need
				;
		}
	}
	
}

define mysql_powered::user($root_password, $user_password)
{
	require mysql_powered::server
	
	$username = $name
	
	exec
	{
		"create mysql user $username": # http://dev.mysql.com/doc/refman/5.5/en/create-user.html
			unless      => "mysqladmin -u '$username' -p'$user_password' status",
			path        => "/bin:/usr/bin",
			command     => "echo \"CREATE USER '$username'@'localhost' IDENTIFIED BY '$user_password'\" | mysql --user='root' --password='$root_password'",
			;
	}
}
