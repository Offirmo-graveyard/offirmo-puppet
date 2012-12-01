
# This class describes a web server able to serve several wordpress (not multi-site).

# creates the wordpress database with an associated user
# creates a dedicated linux user for security (not finished yet)
# deploy a pre-configured wordpress (with several plugins)

class wordpress_server::params
{
	include apache2_powered::params
	$serving_dir = "${apache2_powered::params::dir_serv}/wordpress_instances"
	
	$wordpress_archive="wordpress-3.3-fr_FR_alt.zip" # custom-made archives with theme + plugins included
	
	$wordpress_archive_path="$serving_dir/$wordpress_archive"
}

class wordpress_server()
{
	# apache is the easiest pick
	require apache2_powered
	
	# need mysql capabilities
	require mysql::client
	require mysql::server
	
	include wordpress_server::params
	
	file
	{
		"$wordpress_server::params::serving_dir":
			ensure => directory,
			;
	}
	
} # class wordpress_server


class wordpress_server::common()
{
	include wordpress_server::params
	
	file
	{
		'wordpress-archive':
			path   => "${wordpress_server::params::wordpress_archive_path}",
			source => "puppet:///modules/wordpress_server/${wordpress_server::params::wordpress_archive}",
			ensure => present,
			notify => [ Exec[ "ensure-wordpress-template" ] ],
			;
	}

	exec
	{
		"ensure-wordpress-template":
			#command => "tar xzvf ${wordpress_server::params::wordpress_archive_path} -C ${wordpress_server::params::serving_dir}",
			command => "unzip ${wordpress_server::params::wordpress_archive_path} -d ${wordpress_server::params::serving_dir}",
			unless  => "test -d ${wordpress_server::params::serving_dir}/wordpress",
			path    => "/bin:/usr/bin",
			require => [ File[ 'wordpress-archive', "${wordpress_server::params::serving_dir}" ] ],
			;
	}
	

}


# server_name : SANS le www, exemple : toto.org
# user : both for a unix user and a mysql user
define wordpress_server::serving_instance($server_name, $human_name, $webmaster, $user, $mysql_root_pwd = '', $mysql_user_pwd = '', $copyright_start = '')
{
	include wordpress_server::params
	include wordpress_server::common
	
	$instance_name = $name
	$instance_dir = "${wordpress_server::params::serving_dir}/$instance_name"
	$mysql_user = $user
	$mysql_db_name = $instance_name
	
	# TODO for security reasons, execute the wordpress PHP under this limited user
	# TODO requires an apache extension
	user
	{
		"$user":
			shell      => '/bin/bash',
			#groups     => ['adm', 'admin', 'dialout', 'plugdev'], # without those minimum groups, this user would be useless
			comment    => "User for wordpress site $instance_name,,,",
			managehome => true,
			ensure     => present,
			;
	}
	
	$rights=664
	$owner='www-data' # $user XXX todo executes PHP with $user
	file
	{
		"$instance_dir":
			ensure  => directory,
			owner   => $owner,
			group   => 'www-data', # used by apache
			mode    => $rights,
			recurse => true,
			;
		"$instance_dir/wp-config.php":
			# REM : this template needs $mysql_db_name, $mysql_user, $mysql_user_pwd, $copyright_start
			# and use a trick to generate 64o secret keys : http://stackoverflow.com/questions/88311/how-best-to-generate-a-random-string-in-ruby
			content => template("wordpress_server/wp-config.php.erb"),
			replace => no, # one time init
			require => [ File[ "$instance_dir" ] ],
			;
	}
	exec
	{
		"install wordpress $instance_name":
			unless  => "test -f $instance_dir/wp-app.php", # any file supposed to be here if wp is correctly installed
			command => "cp -r ${wordpress_server::params::serving_dir}/wordpress/* $instance_dir; chown -R $owner:www-data $instance_dir/*; chmod -R $rights $instance_dir/*", # chown is both an optimization and a hack
			path    => "/bin:/usr/bin",
			require => [ Exec[ "ensure-wordpress-template" ], File[ "$instance_dir" ] ],
			;
	}
	
	#notify{ $host: } ?
	
	apache2_powered::with_site
	{
		$instance_name:
			# REM : this template needs $webmaster, $server_name, instance_dir
			config_content => template("wordpress_server/site.erb"),
	}
	
	if ($mysql_root_pwd and $mysql_user_pwd)
	{
		mysql::user
		{
			"$mysql_user":
				root_password => $mysql_root_pwd,
				user_password => $mysql_user_pwd,
				;
		}
		mysql::server::serving_database
		{
			"$mysql_db_name":
				root_password => $mysql_root_pwd,
				user          => $mysql_user,
				require       => Mysql::User[ "$mysql_user" ],
				;
		}
	}
	else
	{
		puppet::impossible_class
		{
			"create-$instance_name-wp-database":
				text => "
I can't create databases for this wordpress
because you didn't give me the necessary passwords.
Please do it yourself.
",
				;
		}
	}
	
	puppet::impossible_class
	{
		"finish-$instance_name-wp-install":
			text => "
Your wordpress has been created but is curently not protected.
Please access http://www.$server
",
			;
	}
}
