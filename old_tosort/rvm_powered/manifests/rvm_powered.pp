
# Ensure that Ruby Version Manager is installed.
# RVM is tricky to install and maintain.

class rvm_powered($version = 'latest', $security = 'yes')
{
	
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
	
	
	####### prerequisites
	# https://rvm.beginrescueend.com/rvm/prerequisites/
	# http://doc.ubuntu-fr.org/rubyonrails#installation_de_ruby
	require git_powered # RVM needs git to install
	require with_tool::bash
	require with_tool::curl
	require with_tool::patch
	require with_tool::build-essential
	# zlib1g-dev libssl-dev libreadline6-dev
	
	
	####### Installation
	# RVM gives a "magic" command to install itself, cf. https://rvm.beginrescueend.com/rvm/install/
	# We need more control, so we keep the "magic command" but break it into separate steps.
	# Last checked 2011/04/18
	
	### Installation preparation
	# We need the installer script.
	# RVM suggest to download it and then sudo exec.
	# It's ok when done manually because we can review the file.
	# But when automating it with puppet, we cannot allow that !
	# Or else, a hacker replacing the installer file
	# can root-run any command he wants on our server !
	# We'll provide our own, checked copy of the installer.
	# This copy is supposed to have been downloaded manually and then checked.
	$rvm_installer_file = '/tmp/rvm-installer'
	if $security == 'no-and-I-really-understand-what-I-do'
	{
		# OK, download the installer from RVM.
		# security issues...
		exec
		{
			'rvm-get-installer':
				# the recommended install command : absolute latest, system wide
				command => "sudo curl -s https://rvm.beginrescueend.com/install/rvm -o $rvm_installer_file";
		} # exec
		# possible race condition ? File safe ?
		file
		{
			"$rvm_installer_file":
				require => Exec['rvm-get-installer'],
				owner   => root,
				group   => root,
				mode    => 755; # restrictive rights, of course.
		} # file
	}
	else
	{
		# we use our own, (hopefully) checked copy of the installer
		file
		{
			"$rvm_installer_file":
				source  => "puppet:///modules/rvm_powered/rvm-installer",
				replace => true, # yes, download it every time, or else someone may replace it !
				owner   => root,
				group   => root,
				mode    => 755; # restrictive rights, of course.
		} # file
	}
	
	# with specific version (but OK if latest)
	exec
	{
		### Installation (if needed)
		'rvm-install':
			command => "sudo $rvm_installer_file --version $version",
			#creates => ["/usr/local/rvm/bin/rvm", "/usr/local/rvm/VERSION"],
			unless  => $version ? {
						'latest' => "test -x /usr/local/rvm/bin/rvm",
						default  => "grep \"$version\" /usr/local/rvm/VERSION",
					},
			require => [ Package['bash', 'curl', 'patch', 'build-essential', 'git-core'], File["$rvm_installer_file"] ],
			notify  => Exec['rvm-reload'];
	}
	
	if $version == 'latest'
	{
		# automatic update
		exec
		{
			### Update (always)
			'rvm-update':
				command  => 'sudo /usr/local/rvm/bin/rvm get head',
				require  => Exec['rvm-install'],
				schedule => rvm_update_period, # This command is a bit long to execute, so we plan it only once in a while.
				notify   => Exec['rvm-reload'];
		}
		# we define what we mean by 'rvm_update_period'
		schedule
		{
			rvm_update_period:
				period => daily,
				range => '2-4'
		}
	}
	
	exec
	{
		'rvm-reload':
			command     => 'sudo /usr/local/rvm/bin/rvm reload',
			refreshonly => true # only when triggered by someone else (see 'notify')
	}
}
