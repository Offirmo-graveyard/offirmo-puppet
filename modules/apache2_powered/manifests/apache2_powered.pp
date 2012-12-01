
# This class represents an apache2 server
# Inspired from http://projects.puppetlabs.com/projects/puppet/wiki/Debian_Apache2_Recipe_Patterns
# and http://wesabe.googlecode.com/svn/trunk/puppet/modules/apache2/trunk/manifests/


class apache2_powered::params
{
	$dir_sites         = "/etc/apache2/sites"
	$dir_mods          = "/etc/apache2/mods"
	$dir_includes      = "/etc/apache2/site-includes"
	$dir_conf          = "/etc/apache2/conf.d"
	$dir_serv_default = "/var/www"
	
	if ($apache2_serving_dir)
	{ $dir_serv = $apache2_serving_dir }
	else
	{ $dir_serv = $dir_serv_default }
}

# a sub-class to solve the dependency problem
# notify + require
class apache2_powered::assets($provider = 'zend')
{
	require apache2_powered::params
	case $provider
	{
		'zend':
		{
			require zend_server_ce_powered
		}
		default:
		{
			err("I'm sorry, I can't recognize the apache2 provider '$provider'.")
		}
	}
	
	file
	{
		$apache2_powered::params::dir_serv:
			owner  => 'www-data',
			group  => 'www-data',
			ensure => directory,
			;
	}
}


# Define an apache2 module. Debian packages place the module config
# into /etc/apache2/mods-available.
#
# You can add a custom require (string) if the module depends on 
# packages that aren't part of the default apache2 package. Because of 
# the package dependencies, apache2 will automagically be included.
define apache2_powered::with_module ( $config_content )
{
	include apache2_powered # and not require ! Since we notify 'apache reload', 'apache2_powered' has a dependency on this class.
	require apache2_powered::assets
	
	$load_file_en = "${apache2_powered::params::dir_mods}-enabled/${name}.load"
	$load_file_av = "${apache2_powered::params::dir_mods}-available/${name}.load"
	$conf_file    = "${apache2_powered::params::dir_mods}-available/${name}.conf"
	
	
	exec
	{
		"/usr/sbin/a2enmod $name": # enable module
			unless  => "/bin/sh -c '[ -L $load_file_en ] && [ $load_file_en -ef $load_file_av ]'",
			notify  => Exec["reload-apache2"],
	}
	file
	{
		$conf_file:
			ensure  => $ensure,
			content => $config_content,
			mode    => 644,
			owner   => root,
			group   => root,
			notify  => Exec["reload-apache2"],
	}
}

# Define an apache2 site. Place all site configs into
# /etc/apache2/sites-available and en-/disable them with this type.
#
# You can add a custom require (string) if the site depends on packages
# that aren't part of the default apache2 package. Because of the
# package dependencies, apache2 will automagically be included.
define apache2_powered::with_site ( $ensure = 'present', $config_content = '' )
{
	include apache2_powered # and not require ! Since we notify 'apache reload', 'apache2_powered' has a dependency on this class.
	require apache2_powered::assets
	
	$site_file_en = "${apache2_powered::params::dir_sites}-enabled/${name}"
	$site_file_av = "${apache2_powered::params::dir_sites}-available/${name}"
	
	# first, make sure the site config exists
	case $config_content
	{
		'':
		{
			file
			{
				$site_file_av:
					mode   => 644,
					owner  => root,
					group  => root,
					ensure => present,
					alias  => "site-$name",
			}
		}
		default:
		{
			file
			{
				$site_file_av:
					content => $config_content,
					mode    => 644,
					owner   => root,
					group   => root,
					ensure  => present,
					alias   => "site-$name",  
			}
		}
	}
	
	# now, enable it.
	exec
	{
		"/usr/sbin/a2ensite $name":
			unless  => "/bin/sh -c '[ -L $site_file_en ] && [ $site_file_en -ef $site_file_av ]'",
			notify  => Exec["reload-apache2"],
			require => File[$site_file_av],
	}
}



class apache2_powered($provider = 'zend')
{
	class
	{
		'apache2_powered::assets':
			provider => $provider,
			# stage => tools,
			;
	}
	
	# Notify this when apache needs a reload. This is only needed when
	# sites are added or removed, since a full restart then would be
	# a waste of time. When the module-config changes, a force-reload is
	# needed.
	exec
	{
		"reload-apache2":
			command     => "/etc/init.d/apache2 reload",
			refreshonly => true, # when asked via 'notify'
	}
	
	# useful for ?
	# exec
	# {
		# "force-reload-apache2":
			# command     => "/etc/init.d/apache2 force-reload",
			# refreshonly => true,
	# }
	
	# We want to make sure that the service is running.
	# service
	# {
		# "apache2":
			# ensure     => running,
			# hasstatus  => true,
			# hasrestart => true,
			# require    => Package['apache2'],
	# }
}