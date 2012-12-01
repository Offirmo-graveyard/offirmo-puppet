
# This class describes a web server able to serve several rails apps.
# There is another class below to describe the rail app itself.


# passenger apt repository
# cf. http://blog.brightbox.co.uk/posts/nginx-passenger-3-ubuntu-packages
class with_passenger_apt_repository
{
	apt_powered::ppa_apt_repository
	{
		passenger_ppa_apt_repository:
			ppa => 'ppa:brightbox/passenger'
	}
} # class with_passenger_apt_repository


# install passenger apache module
# and other necessary
class passenger_powered($ruby_rvm_name)
{
	require apache2_powered::assets
	
	class
	{
		with_passenger_apt_repository:
			stage => apt
	}
	
	$gemset_name = 'passenger_gemset'
	
	
	# Preparation : we set the pathes for all 'exec' resources in this scope.
	Exec {
		path => [
				'/usr/local/bin',
				'/opt/local/bin',
				'/usr/bin',
				'/usr/sbin',
				'/bin',
				'/sbin' ],
		logoutput => true,
	} # Exec
	
	# here we use 'exec' instead of 'package'
	# because I haven't found how to pass '--force-yes' via the 'package' resource type.
	# It's OK because this command can be run multiple times without risks.
	exec
	{
		'install-passenger-package':
			command => 'sudo apt-get install libapache2-mod-passenger --yes --force-yes',
			# of course, apache must be already installed. Should be done via require apache2_powered::assets
			;
	}
	
	apache2_powered::with_module
	{
		"passenger":
			config_content => template("rails_server/passenger.conf.erb"),
			require        => Exec['install-passenger-package'];
	}
	
	rvm_powered::gemset
	{
		"create-passenger-default-gemset":
			ruby_rvm_name => $ruby_rvm_name,
			gemset_name   => $gemset_name,
	}
} # class with-passenger



class rails_server::params
{
	include apache2_powered::params
	$serving_dir = "${apache2_powered::params::dir_serv}/rails_apps"
}

class rails_server($ruby_rvm_name)
{
	# apache is the best server
	require apache2_powered
	# most apps need mysql capabilities
	require mysql::client
	
	
	file
	{
		$rails_server::params::serving_dir:
			ensure => directory,
			;
	}
	
	# Looks like there is a dependency to sqlite3 in common gems.
	# It doesn't hurt...
	package
	{
		'libsqlite3-dev':
			ensure => latest, # usually used for testing, latest is OK
			;
	}
	
	class
	{
		# and passenger the best way to host a rails app
		passenger_powered:
			ruby_rvm_name => $ruby_rvm_name,
	}
	
} # class rails_server




define rails_server::serving_rails_app($app_name, $host, $webmaster, $app_dir, $username, $mysql_root_pwd = '', $mysql_prod_db_pwd = '', $mongodb_root_pwd = '')
{
	$site_dir = "$app_dir/public"
	
	notify{ $host: }
	
	apache2_powered::with_site
	{
		$app_name:
			config_content => template("rails_server/site.erb"),
	}
	
	file
	{
		"$app_dir/config/database.yml":
			owner   => $username,
			group   => $username,
			mode    => 644,
			ensure  => present,
			content => template("rails_server/database.yml.erb"), # $mysql_prod_db_pwd is used in this template
			require => File[$app_dir],
			;
	}
	
	if $mysql_root_pwd
	{
		mysql::server::serving_database
		{
			[ "${project}_prod", "${project}_dev", "${project}_test" ]:
				root_password => $mysql_root_pwd;
		}
		puppet::impossible_class
		{
			"create-mysql-users-for-app-$app_name":
				text => "
I can't manage to automatically create the MySQL users for app $app_name...
Please look at $app_dir/conf/database.yml and create the MySQL users with the given passwords.
",
				;
		}
	}
	
	if $mongodb_root_pwd
	{
		err("TODO")
	}
	
	puppet::impossible_class
	{
		"bundle-install-for-app-$app_name":
			text => "
I can't manage to automatically do bundle install for app $app_name...
Please go to $app_dir and type 'bundle install'
",
			;
		
		"db-migrate-for-app-$app_name":
			text => "
I can't manage to automatically do db:migrate for app $app_name...
Please go to $app_dir and type
	bundle exec rake db:migrate (for dev env)
	RAILS_ENV=production bundle exec rake db:migrate (for prod env)
	
(Of course, MySQL users should have been created with correct pwds, cf. another toto)
",
			;
	}
}
