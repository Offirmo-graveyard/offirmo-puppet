
# Everything related to apt repositories :
# - main "sources.list" file
# - additional sources in sources.list.d
# - gpg keys
# - ppa repositories
# - automatic 'apt-get update' whenever a source is changed, or periodically else.
#
# WARNING : since there are 'notify' in thos classes, dependencies cycles may happen if not handled properly.
#
# inspired from http://projects.puppetlabs.com/projects/puppet/wiki/Apt_Repositories_Patterns





# This defined resource represents an apt repository.
# Instead of adding a line in /etc/apt/sources.list, which is complicated and hard to monitor,
# we use a more convenient way : adding a specific file in /etc/apt/sources.list.d
# It works the same, and we can manage our repositories individually.
# example : 
#		apt_powered::apt_repository
#		{
#			zend_apt_repository:
#				name     => 'zend-server',
#				address  => 'http://repos.zend.com/zend-server/deb',
#				branch   => 'server',
#				sections => 'non-free',
#				comment  => 'Special repository for Zend Server',
#				key_addr => 'http://repos.zend.com/zend.key',
#		}
#
define apt_powered::apt_repository($name, $address, $branch = $::lsbdistcodename, $sections = 'main', $comment = 'a repository', $with_src = false, $key_addr = '')
{
	include apt_powered # and not require ! Since we notify apt-get update, 'apt_powered' has a dependency on this class.
	require with_tool::wget
	
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
	
	# the file were we'll write the repository infos
	# /etc/apt/sources.list.d/xxx.list
	$target  = "${apt_powered::sources_dir}/${name}.list"
	# the content of the file
	$content = "
## $comment
deb $address $branch $sections
"
	if $with_src
	{
		$content = $content + "deb-src $address $branch $sections\n"
	}
	
	# debug
	if false
	{
		notify
		{
			'apt_repository_debug_1':
				message => "apt_repository :
- name    = $name
- address = $address
- stuff   = $stuff
- comment = $comment
";
			'apt_repository_debug_2':
				message => "file target : $target";
			'apt_repository_debug_3':
				message => "content for $target : $content";
		}
	} # debug
	
	# the source file
	file
	{
		"apt-$name-repository":
			path    => $target,
			owner   => root,
			group   => root,
			mode    => 644,
			content => $content,
			notify  => Exec['sudo apt-get update']; # Notify the need for a refresh, see below.
			                                        # Update is scheduled regularly, but we don't want to wait if this file is modified.
	}
	
	# the key (if any)
	if $key_addr != ''
	{
		exec
		{
			"get-$name-repository-key":
				command     => "wget $key_addr -O- | sudo apt-key add -",
				require     => Package['wget'],
				subscribe   => File["apt-$name-repository"],
				refreshonly => true,
				notify      => Exec['sudo apt-get update']; # Notify the need for a refresh, see below.
		}
	}
} # defined resource apt_repository





# This defined resource represents a ppa apt repository.
# Instead of adding a line in /etc/apt/sources.list, which is complicated and hard to monitor,
# we'll use a more convenient way : adding a specific file in /etc/apt/sources.list.d
# It works the same, and we can manage our repositories individually.
# example : 
#		apt_powered::ppa_apt_repository
#		{
#			igraph_ppa_apt_repository:
#				ppa => 'ppa:igraph/ppa'
#		}
#
# ppa:mathiaz/puppet-backports
# 
define apt_powered::ppa_apt_repository($ppa, $override_branch = '')
{
	include apt_powered # and not require ! Since we notify apt-get update, 'apt_powered' has a dependency on this class.
	require with_tool::python-software-properties # The 'add-apt-repository' tool is in the package 'python-software-properties'.
	
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
	
	
	# First we need to parse the ppa address to extract infos
	# I can't manage to use the puppet 'split' function, so I use the ruby one
	$pparad = inline_template("<%= \"$ppa\".split(':')[0] %>")
	
	if $pparad != 'ppa'
	{
		err("It looks like the ppa adress \"$ppa\" is not what I expect. Please investigate.")
	}
	else
	{
		$part1  = inline_template("<%= \"$ppa\".split(':')[1].split('/')[0] %>")
		$part2  = inline_template("<%= \"$ppa\".split(':')[1].split('/')[1] %>")
		
		# the file were we'll write the repository infos
		# /etc/apt/sources.list.d/xxx.list
		# ppa:igraph/ppa   =>   igraph-ppa-maverick.list
		# ppa:mathiaz/puppet-backports   =>   mathiaz-puppet-backports-maverick.list
		$target  = "${apt_powered::sources_dir}/${part1}-${part2}-$::lsbdistcodename.list"
		
		# debug
		if false
		{
			notify
			{
				'ppa_apt_repository_debug_1':
					message => "automatic_ppa_apt_repository :
- address = $ppa, splitted into :
  - ppa   = $pparad
  - part1 = $part1
  - part2 = $part2
";
				'ppa_apt_repository_debug_2':
					message => "file target : $target";
			}
		} # debug
		
		
		exec
		{
			"install-$name-ppa-apt-repository":
				command => "sudo add-apt-repository $ppa",
				unless  => "test -f $target",
				notify  => Exec['sudo apt-get update'], # update is scheduled daily, but we don't want to wait if this file is modified.
				require => Package['python-software-properties'];
		}
		
		if ($override_branch) and ($override_branch != $::lsbdistcodename)
		{
			# we'll rewrite the file generated by add-apt-repository
			#
			# Example : mathiaz/puppet-backports only has a 'lucid' branch, so we have to rewrite if we are under maverick for example.
			# ppa:mathiaz/puppet-backports
			# => deb http://ppa.launchpad.net/mathiaz/puppet-backports/ubuntu maverick main
			# => deb-src http://ppa.launchpad.net/mathiaz/puppet-backports/ubuntu maverick main
			#
			$address  = "http://ppa.launchpad.net/$part1/$part2/ubuntu"
			$branch   = $override_branch
			$sections = "main"
			
			$content = "
## rewritten with branch $override_branch
deb $address $branch $sections
deb-src $address $branch $sections
"
			file
			{
				$target:
					require => Exec["install-$name-ppa-apt-repository"],
					content => $content,
					notify  => Exec['sudo apt-get update'], # update is scheduled daily, but we don't want to wait if this file is modified.
				;
			}
		} # $override_branch ?
	} # ppa check
} # defined resource ppa_apt_repository




# Use on development machine only !!!
class apt_powered::upgraded
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
	
	exec
	{
		'sudo apt-get upgrade':
			command   => 'sudo apt-get upgrade -y', # -y to assume yes to all
			subscribe => Exec['sudo apt-get update'],
			;
	}
}




class apt_powered($offline = 'false')
{
	# declarations
	$apt_dir           = "/etc/apt" # directory where packages repositories declarations lies
	$sources_main_file = "${apt_dir}/sources.list"
	$sources_dir       = "${apt_dir}/sources.list.d"
	
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
	
	# apt only works for debian-based systems, we add a check :
	case $operatingsystem
	{
		# debian based : OK
		debian, ubuntu:
		{
			# Staged pre-declarations.
			# Those classes are an indirect dependency,
			# but puppet can't infer the required stage via require.
			# So we have to declare them here to enforce the stage and avoid loops.
			class
			{
				'with_tool::wget':
					stage => apt;
				'with_tool::python-software-properties': # idem
					stage => apt;
			}
			
			notify
	{
		debug:
			message => "${::lsbdistid}-${::lsbdistcodename}-sources.list";
	}

			# The main packages repositories declaration file
			file { '/etc/apt/sources.list':
				source => "puppet:///modules/apt_powered/${::lsbdistid}-${::lsbdistcodename}-sources.list",
				owner  => root,
				group  => root,
				mode   => 644,
				notify => Exec['sudo apt-get update']; # Notify the need for a refresh, see below.
				                                       # Update is scheduled regularly, but we don't want to wait if this file is modified.
			}
			
			
			# This is a way to have apt-get update launched regularly.
			# (I don't remember where I found that)
			# Note : automatic execution will not happen. Puppet must be run at last daily for it to work.
			exec
			{
				'sudo apt-get update':
					schedule => apt-get-update-period,
					command  => $offline ? {
						'false' => 'sudo apt-get update',
						default => 'echo "no apt get update because we are offline..."',
						},
					;
			}
			# we define what we mean by 'apt-get-update-period'
			schedule
			{
				apt-get-update-period:
					period => daily,
					range => '2-4'
			}
		} # case $operatingsystem = debian like
		default:
		{
			err("This class is for Debian-derived systems, but ${fqdn} runs ${operatingsystem}.")
		} # $operatingsystem not handled
	} # $operatingsystem check
} # class apt-powered
