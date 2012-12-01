####### Puppet nodes definition #######


### stages ###
## Very important : we define stages.
## Can only be done here.
stage { 'first': }      # the first of first
stage { 'apt': }        # to install apt sources and run apt-get update if necessary
# stage main            # default stage, always available
stage { 'last': }       # a stage after all the others
# Now we define the order :
Stage[first] -> Stage[apt] -> Stage[main] -> Stage[last]






####### NOMRPG server #######
import "nomrpg_secrets.pp"
#node ip-10-227-205-129
node ubuntuserver3
{
	include nomrpg::secrets
	
	# Redefinition of apache serving dir.
	# (to match the dev server, easier)
	file {  '/srv/dev':	ensure  => directory ; }
	$apache2_serving_dir = '/srv/dev/www'
	
	# basic
	# We use the "class" syntax here because we need to specify a run stage.
	class
	{
		### classes with explicit stages
		'puppeted': # debug
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
	
	#$MySQL_root_password = $nomrpg::secrets::MySQL_root_password
	$contact_email       = $nomrpg::secrets::contact_email
	
	class
	{
		'ssmtp_powered':
			template => 'gmail',
			email    => $contact_email,
			password => $nomrpg::secrets::gmail_password,
			;
		'git_powered':
			;
	}
}



####### Current dev machine #######
import "ubuntuserver4_secrets.pp"

node ubuntuserver33
{
	include ubuntuserver4::secrets
	
	# A generic user
	# XXX TODO review
	user
	{
		'admyn':
			shell      => '/bin/bash',
			groups     => ['adm', 'admin', 'dialout', 'plugdev'], # without those minimum groups, this user would be useless
			comment    => "Generic user,,,",
			managehome => true,
			ensure     => present,
			;
	}
	
	# basics needing a run state
	# We use the "class" syntax here because we need to specify a run stage.
	class
	{
		'puppeted': # debug
			stage   => first, # note the explicit stage !
			;
		'apt_powered': # Very important for managing apt sources
			stage   => apt, # note the explicit stage !
			#offline => 'true', # uncomment this if you are offline or don't want updates
			;
		'apt_powered::upgraded': # will systematically upgrade paquets. dev machine -> we want to stay up to date
			stage   => apt, # note the explicit stage !
			;
	}
	
	# basics, second part
	class
	{
		'puppet::client': # of course ;-)
			;
		'ubuntu_virtualbox':
			;
		'offirmo_ubuntu':
			;
		#'offirmo_aws_instance':
		#	;
	}
	
	### The roles of this machine
	
} # node ...


node toto
{
	class
	{
		'cpp_powered::development':
			owner => 'admyn',
			;
	}

	cpp_powered::with_lib
	{
		'boost':
			;
		'wt':
			;
	}
	
	## an alternate env
	cpp_powered::with_compile_env
	{
		'gcc47': # this is the "technical name"
			compiler_name    => 'gcc',
			compiler_version => '47',
			;
	}
	cpp_powered::with_lib
	{
		'boost47':
			lib         => 'boost',
			compile_env_id => 'gcc47',
			;
		'wt47':
			lib         => 'wt',
			compile_env_id => 'gcc47',
			;
	}
}

####### Kalemya charity server #######
import "kalemya_secrets.pp"
node ip-10-228-235-142
{
	include kalemya::secrets
	
	# Redefinition of apache serving dir.
	# (to match the dev server, easier)
	file {  '/srv/dev':	ensure  => directory ; }
	$apache2_serving_dir = '/srv/dev/www'
	
	# basic
	# We use the "class" syntax here because we need to specify a run stage.
	class
	{
		### classes with explicit stages
		'puppeted': # debug
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
	
	### The main roles of this machine
	$MySQL_root_password = $kalemya::secrets::MySQL_root_password
	$contact_email       = $kalemya::secrets::contact_email
	
	class
	{
		'zend_server_ce_powered':
			;
		'mysql::server':
			password => $MySQL_root_password,
			;
		'wordpress_server':
			;
	}
	class
	{
		'ssmtp_powered':
			template => 'gmail',
			email    => $contact_email,
			password => $kalemya::secrets::gmail_password,
			;
	}
	
	wordpress_server::serving_instance
	{
		'kalemya': # this is the "technical name"
			human_name     => 'Kalemya',
			server_name    => 'kalemya.org',
			webmaster      => $contact_email,
			user           => 'kal',
			mysql_root_pwd => $MySQL_root_password,
			mysql_user_pwd => $kalemya::secrets::MySQL_worpress_db_password,
			;
	}
}


####### 10km charity server #######
import "les10kiloMEP_secrets.pp"
node ip-10-58-182-166
{
	include les10kiloMEP::secrets
	
	# Redefinition of apache serving dir.
	# (to match the dev server, easier)
	file {  '/srv/dev':	ensure  => directory ; }
	$apache2_serving_dir = '/srv/dev/www'
	
	# basic
	# We use the "class" syntax here because we need to specify a run stage.
	class
	{
		### classes with explicit stages
		'puppeted': # debug
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
	
	### The main roles of this machine
	$MySQL_root_password = $les10kiloMEP::secrets::MySQL_root_password
	$contact_email       = $les10kiloMEP::secrets::contact_email
	
	class
	{
		'zend_server_ce_powered':
			;
		'mysql::server':
			password => $MySQL_root_password,
			;
		'wordpress_server':
			;
	}
	class
	{
		'ssmtp_powered':
			template => 'gmail',
			email    => $contact_email,
			password => $les10kiloMEP::secrets::gmail_password,
			;
	}
	
	wordpress_server::serving_instance
	{
		'les10kilomep': # this is the "technical name"
			human_name     => 'Les 10 kilo\'MEP',
			server_name    => 'les10kilomep.org',
			webmaster      => $contact_email,
			user           => 'l10km',
			mysql_root_pwd => $MySQL_root_password,
			mysql_user_pwd => $les10kiloMEP::secrets::MySQL_worpress_db_password,
			;
	}
}



####### Current dev machine #######
import "ubuntuserver3_secrets.pp"

node ubuntuserver3old
{
	include les10kiloMEP::secrets
	include kalemya::secrets
	include ubuntuserver3::secrets
	
	# redefinition of apache serving dir
	# we want the directory to be in the shared folder
	$apache2_serving_dir = '/srv/dev/www'
	
	# A generic user
	user
	{
		'admyn':
			shell      => '/bin/bash',
			groups     => ['adm', 'admin', 'dialout', 'plugdev'], # without those minimum groups, this user would be useless
			comment    => "Generic user,,,",
			managehome => true,
			ensure     => present,
			;
	}
	
	# basics
	# We use the "class" syntax here because we need to specify a run stage.
	class
	{
		'puppeted': # debug
			stage   => first, # note the explicit stage !
			;
		'apt_powered': # Very important for managing apt sources
			stage   => apt, # note the explicit stage !
			#offline => 'true', # uncomment this if you are offline (no updates)
			;
		'apt_powered::upgraded': # dev machine, we want to stay up to date
			stage   => apt, # note the explicit stage !
			;
	}
	# basics, second part
	class
	{
		'puppet::client': # of course ;-)
			;
		'ubuntu_vmware':
			;
		'offirmo_ubuntu':
			;
		#'offirmo_aws_instance':
		#	;
	}
	
	### The roles of this machine
	# basics
	$MySQL_root_password = $ubuntuserver3::secrets::MySQL_root_password
	class
	{
		'zend_server_ce_powered':
			;
		'zend_server_ce_powered::phpmyadmin::with-extended-session-time':
			;
		'mysql::server':
			password => $MySQL_root_password,
			;
		'git_powered':
			;
		'svn_powered':
			;
		'java_powered':
			;
	}
	# Wt
	class
	{
		'cpp_powered::development':
			;
		'wt_powered::development':
			;
		'with_tool::cmake':
			;
	}
	# wordpress
	class
	{
		'ssmtp_powered':
			template => 'gmail',
			email    => $ubuntuserver3::secrets::contact_email,
			password => $ubuntuserver3::secrets::gmail_password,
			;
	}
	class
	{
		'wordpress_server':
			;
	}
	wordpress_server::serving_instance
	{
		'les10kilomep': # this is the "technical name"
			human_name     => 'Les 10 kilo\'MEP',
			server_name    => 'les10kilomep.org',
			webmaster      => $les10kiloMEP::secrets::contact_email,
			user           => 'l10km',
			mysql_root_pwd => $MySQL_root_password,
			mysql_user_pwd => $les10kiloMEP::secrets::MySQL_worpress_db_password,
			;
		'kalemya': # this is the "technical name"
			human_name     => 'Kalemya',
			server_name    => 'kalemya.org',
			webmaster      => $les10kiloMEP::secrets::contact_email,
			user           => 'kal',
			mysql_root_pwd => $MySQL_root_password,
			mysql_user_pwd => $kalemya::secrets::MySQL_worpress_db_password,
			;
	}
} # node ...
