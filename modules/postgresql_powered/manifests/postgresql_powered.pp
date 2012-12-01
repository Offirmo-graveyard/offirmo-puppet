
class postgresql_powered::params()
{
	$phppgadmin_archive = "phpPgAdmin-5.0.4.tar.bz2"
	$phppgadmin_archive_path = "/srv/www/$phppgadmin_archive"
}


class postgresql_powered::common()
{
	# postgresql-client
}

class postgresql_powered::server()
{
	class
	{
		'postgresql_powered::common':
			;
	}
	
	package
	{
		'postgresql':
			ensure => latest, # This packages is security critical, we must use 'latest'
			;
	}

} # class postgresql_powered::server

class postgresql_powered::with_phppgadmin()
{
	# apache is the easiest pick
	require apache2_powered
	
	include postgresql_powered::params

	package
	{
		'phppgadmin':
			ensure => latest, # This packages is security critical, we must use 'latest'
			;
	}
	
	file
	{
		'phppgadmin-archive':
			path   => "${postgresql_powered::params::wordpress_archive_path}",
			source => "puppet:///modules/postgresql_powered/${postgresql_powered::params::phppgadmin_archive}",
			ensure => present,
			notify => [ Exec[ "ensure-phppgadmin" ] ],
			;
	}

	exec
	{
		"ensure-phppgadmin":
			#command => "tar xzvf ${postgresql_powered::params::wordpress_archive_path} -C ${wordpress_server::params::serving_dir}",
			command => "unzip ${wordpress_server::params::phppgadmin_archive_path} -d ${wordpress_server::params::serving_dir}",
			unless  => "test -d ${wordpress_server::params::serving_dir}/wordpress",
			path    => "/bin:/usr/bin",
			require => [ File[ 'phppgadmin-archive' ] ],
			;
	}
	
	apache2_powered::with_site
	{
		"phppgadmin":
			# REM : this template needs $webmaster, $server_name, instance_dir
			config_content => template("wordpress_server/site.erb"),
	}
}
}