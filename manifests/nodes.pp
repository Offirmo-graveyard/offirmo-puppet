####### Puppet nodes definition #######
## for an Ubuntu, by Offirmo
## https://github.com/Offirmo/offirmo-puppet
## http://offirmo.net/


### stages ###
## Very important : we define stages.
## This can only be done here.
stage { 'first': }      # the first of first
stage { 'apt': }        # to install apt sources and run apt-get update if necessary
# stage main            # default stage, always available
stage { 'last': }       # a stage after all the others
# Now we define the relative order :
Stage[first] -> Stage[apt] -> Stage[main] -> Stage[last]






####### Kal+10k server #######
import "kalemya_secrets.pp"
import "les10kiloMEP_secrets.pp"
node ip-10-228-75-167
#node ubuntuserver7
{
	## the passwords and misc credentials
	include kalemya::secrets
	include les10kiloMEP::secrets
	$MySQL_root_password = $kalemya::secrets::MySQL_root_password
	$contact_email       = $les10kiloMEP::secrets::contact_email
	$gmail_password      = $les10kiloMEP::secrets::gmail_password


	## base classes of this machine
	## that need a specific stage.
	## We use the "class" syntax here which allow us to specify a run stage.
	class
	{
		'puppeted': # this only cause debug display for the various stages
			stage   => first,
			;
		'apt_powered': # Very important for managing apt sources
			stage   => apt,
			;
	}
	## basics, second part (no stages)
	class
	{
		'ubuntu_base': # hardware/drivers install (mostly virtualization additions)
			;
		'offirmo_ubuntu': # useful packages and users
			;
		'puppet_powered::client': # of course ;-)
			;
	}

	### The roles of this machine
	class
	{
		# simple SMTP, for mail capabilities
		'ssmtp_powered':
			template => 'gmail',
			email    => $contact_email,
			password => $gmail_password,
			;
		'lamp_powered::dev':
			mysql_root_password => $MySQL_root_password,
			;
		'apache2_powered':
			;
	}


	class
	{
		'wordpress_server':
			mysql_root_pwd => $MySQL_root_password,
			;
	}
	wordpress_server::serving_instance
	{
		'les10kilomep': # this is the "technical name"
			human_name     => "Les 10 kilo\'MEP",
			server_name    => 'les10kilomep.org',
			webmaster      => $les10kiloMEP::secrets::contact_email,
			user           => 'l10km',
			mysql_root_pwd => $MySQL_root_password,
			mysql_user_pwd => $les10kiloMEP::secrets::MySQL_worpress_db_password,
			;
	}
	wordpress_server::serving_instance
	{
		'kalemya': # this is the "technical name"
			human_name     => 'Kalemya',
			server_name    => 'kalemya.org',
			webmaster      => $kalemya::secrets::contact_email,
			user           => 'kal',
			mysql_root_pwd => $MySQL_root_password,
			mysql_user_pwd => $kalemya::secrets::MySQL_worpress_db_password,
			table_prefix   => 'wpkal_',
			;
	}
	wordpress_server::serving_instance
	{
		'lesvieux10kilomep': # this is the "technical name"
			human_name     => "Les vieux 10 kilo\'MEP",
			server_name    => 'vieux.les10kilomep.org',
			webmaster      => $les10kiloMEP::secrets::contact_email,
			user           => 'vieuxl10km',
			mysql_root_pwd => $MySQL_root_password,
			mysql_user_pwd => $les10kiloMEP::secrets::MySQL_worpress_db_password_old,
			;
	}
}


####### NOMRPG server #######
import "nomrpg_secrets.pp"
#node ip-10-39-13-72
node ubuntuserver7x
{
	## the passwords and misc credentials
	include nomrpg::secrets
	$MySQL_root_password = $nomrpg::secrets::MySQL_root_password
	$contact_email       = $nomrpg::secrets::contact_email
	$gmail_password      = $nomrpg::secrets::gmail_password


	## base classes of this machine
	## that need a specific stage.
	## We use the "class" syntax here which allow us to specify a run stage.
	class
	{
		'puppeted': # this only cause debug display for the various stages
			stage   => first,
			;
		'apt_powered': # Very important for managing apt sources
			stage   => apt,
			;
	}
	## basics, second part (no stages)
	class
	{
		'ubuntu_base': # hardware/drivers install (mostly virtualization additions)
			;
		'offirmo_ubuntu::dev': # useful packages and users
			;
		'puppet_powered::client': # of course ;-)
			;
	}

	### The roles of this machine
	class
	{
		# simple SMTP, for mail capabilities
		'ssmtp_powered':
			template => 'gmail',
			email    => $contact_email,
			password => $gmail_password,
			;
		'lamp_powered::dev':
			mysql_root_password => $MySQL_root_password,
			;
		#'ruby_powered::dev':
		#	;
		'cpp_powered::dev':
			;
		'shell_powered::dev':
			;
		'puppet_powered::dev':
			;
	}


	include lmpt::secrets
	mysql_powered::server::serving_database
	{
		'lmpt': # this is the "technical name"
			root_password => $MySQL_root_password,
			user          => 'lmpt',
			;
	}
	mysql_powered::user
	{
		'lmpt': # this is the "technical name"
			root_password => $MySQL_root_password,
			user_password => $lmpt::secrets::MySQL_lmpt_db_password,
			;
	}
	apache2_powered::with_standard_site
	{
		'lmpt':
			contact_email => $contact_email,
			server_hostname => 'lmpt.offirmo.net',
			serving_dir => '/work/www/lmpt',
			;
	}


	include les10kiloMEP::secrets
	class
	{
		'wordpress_server':
			mysql_root_pwd => $MySQL_root_password,
			;
	}
	#wordpress_server::serving_instance
	#{
	#	'les10kilomep': # this is the "technical name"
	#		human_name     => "Les 10 kilo\'MEP",
	#		server_name    => 'les10kilomep.org',
	#		webmaster      => $contact_email,
	#		user           => 'l10km',
	#		mysql_root_pwd => $MySQL_root_password,
	#		mysql_user_pwd => $les10kiloMEP::secrets::MySQL_worpress_db_password,
	#		;
	#}
}



####### LMPT server #######
import "lmpt_secrets.pp"
node ip-10-227-45-60
#node ubuntuserver6
{
	include lmpt::secrets

	# a place where we'll put our work data
	file
	{
		'/work':
			ensure  => directory,
			;
		'/work/home':
			ensure  => directory,
			;
		'/work/shell':
			ensure  => directory,
			;
		'/work/puppet':
			ensure  => directory,
			;
		'/work/cpp':
			ensure  => directory,
			;
		#'/work/www':   xxx no, this one will be created by a module
		#	ensure  => directory,
		#	;
		'/work/misc':
			ensure  => directory,
			;
	}
	
	# Redefinition of apache serving dir
	# apache will declare and create thi dir
	$apache2_serving_dir = '/work/www'
	
	# basic
	# We use the "class" syntax here because we need to specify a run stage.
	class
	{
		### classes with explicit stages
		'puppeted': # mainly debug display
			stage   => first,
			;
		'apt_powered': # Very important for managing apt sources
			stage   => apt,
			;
	}
	# basics, second part
	class
	{
		'puppet::client': # of course ;-)
			;
		'offirmo_ubuntu': # includes an "altadmin" user
			;
		'offirmo_aws_instance':
			;
	}
	
	### The roles of this machine
	
	# shortcuts for frequently used vars 
	$MySQL_root_password = $lmpt::secrets::MySQL_root_password
	$contact_email       = $lmpt::secrets::contact_email
	
	class
	{
		'zend_server_ce_powered':
			;
		'ssh_powered':
			;
		'git_powered':
			;
	}
	class
	{
		'mysql_powered::server':
			password => $MySQL_root_password,
			;
	}
	class
	{
		'ssmtp_powered':
			template => 'gmail',
			email    => $contact_email,
			password => $lmpt::secrets::gmail_password,
			;
	}

	mysql_powered::user
	{
		'lmpt': # this is the "technical name"
			root_password => $MySQL_root_password,
			user_password => $lmpt::secrets::MySQL_lmpt_db_password,
			;
	}
	mysql_powered::server::serving_database
	{
		'lmpt': # this is the "technical name"
			root_password => $MySQL_root_password,
			user          => 'lmpt',
			;
	}
	apache2_powered::with_standard_site
	{
		'lmpt':
			contact_email => $contact_email,
			server_hostname => 'lmpt.offirmo.net',
			serving_dir => '/work/www/lmpt',
			;
	}
}

# config_content => '<VirtualHost *:80>
# 	ServerName lmpt.offirmo.net
# 	ServerAdmin offirmo.net@gmail.com
# 	DocumentRoot /work/www/lmpt
# 	ErrorLog /var/log/apache2/lmpt-error_log
# 	TransferLog /var/log/apache2/lmpt-access_log
# 	<Directory /work/www/lmpt>
# 		AllowOverride all
# 		Options FollowSymLinks -MultiViews
# 	</Directory>
# </VirtualHost>'
