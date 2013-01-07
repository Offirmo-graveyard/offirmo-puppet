
# This class represents a zend server CE = apache bundled by the Zend company
# I use this one instead of a raw apache because Zend bundle a web interface for status and logs

class with_zend_apt_repository
{
	apt_powered::apt_repository
	{
		zend_apt_repository:
			reponame => 'zend-server',
			address  => 'http://repos.zend.com/zend-server/deb',
			branch   => 'server',
			sections => 'non-free',
			comment  => 'Special repository for Zend Server',
			key_addr => 'http://repos.zend.com/zend.key',
	}
} # class with-zend-apt-repository


class zend_server_ce_powered($php_version = '5.3')
{
	require with_tool::build-essential
	
	class
	{
		with_zend_apt_repository:
			stage => apt;
	}
	
	package
	{
		# the main package
		'zend-server-ce':
			name    => "zend-server-ce-php-$php_version",
			ensure  => present; # this package is critical and updates should be supervised. We don't use 'latest'.
		# I believe this package is useful even in production, to do maintenance.
		'phpmyadmin-zend-server':
			ensure  => latest, # this package is not run-critical but is security critical. We must use 'latest'.
			require => Package['zend-server-ce'];
	} # packages
	
	puppet_powered::impossible_class
	{
		"set-a-password-for-zend-ce-web-admin-interface":
			text => "
I can't manage to automatically set a password for zend-ce web admin interface.
Please visit immediately http://127.0.0.1:10081
and set a password.
",
			;
	}
	
	file
	{
		'lighttpd-config-file':
			path    => '/usr/local/zend/gui/lighttpd/etc/lighttpd.conf',
			require => Package['zend-server-ce'],
			notify  => Exec['admin-restart'],
			;
	}
	
	puppet_powered::impossible_class
	{
		"make-phpmyadmin-accessible-from-outside-localhost":
			text => "
I can't manage to automatically make phpmyadmin accessible from outside hosts...
Please edit this file : /usr/local/zend/gui/lighttpd/etc/lighttpd.conf
Find this :

$HTTP[\"remoteip\"] !~ \"127.0.0.1\" {
	$HTTP[\"url\"] =~ \"^/phpmyadmin/\" {

and add a * in url.access-deny :

		url.access-deny = ( \"*\" )

You will then need to restart the server serving phpmyadmin :

	sudo /usr/local/zend/bin/zendctl.sh restart

(instructions taken from http://www.mogilowski.net/lang/en-us/2009/12/17/zend-server-community-edition-on-ubuntu-server/)
",
			;
	}
	
	# et on install d'office le plugin mongo pour php
	#exec
	#{
	#	'install-mongo-php-module':
	#		command => '/usr/bin/sudo /usr/local/zend/bin/pecl install mongo',
	#		returns => [0, 1], # don't care if it fails, means it's already installed
	#		require => Package['zend-server-ce'],
	#}
	#puppet::impossible_class
	#{
	#	"reboot-apache-after-adding-mongo-module":
	#		text => "
#I'm lazy so it's not automated. Just restart the apache server (if not already done) :
#	sudo /etc/init.d/apache2 reload
#",
#			;
#	}
	#file
	#{
	#	'/usr/local/zend/etc/conf.d/mongo.ini':
	#		ensure  => present,
	#		content => "
#extension=mongo.so
#; You may put any extension-specific directives here
#",
	#		require => Exec['install-mongo-php-module'],
	#		# should notify apache2 restart, but too complicated. User will do it himself.
	#}
	
	exec
	{
		'admin-restart':
			command     => 'sudo /usr/local/zend/bin/zendctl.sh restart',
			path        => '/usr/bin',
			refreshonly => true, # of course, this command should be run only if the config file was modified
			subscribe   => File['lighttpd-config-file'];
	}
	
} # class zend_server_ce_powered


class zend_server_ce_powered::phpmyadmin::with-extended-session-time
{
	# this file is not usually present, so we can set the content freely
	file
	{
		'phpmyadmin-config-file':
			path    => '/var/lib/phpmyadmin/config.inc.php',
			require => Package['phpmyadmin-zend-server'],
			content => "
<?php
	$cfg['LoginCookieValidity'] = 3600 * 9; // 9 hours
?>",
			notify  => Exec['admin-restart'],
			replace => false, # if there is already a file, don't replace
			;
	}
}
