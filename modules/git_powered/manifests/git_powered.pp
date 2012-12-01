
# Ensure that the git source control tool is present.

class git_powered
{
	package
	{
		'git-core':
			ensure => present; # this package is critical and updates should be supervised. We don't use 'latest'.
	} # package
	
} # class git_powered


class git_powered::with_github_host_allowed
{
	require ssh_powered
	
	# Those are the github keys, hashed for confidentiality
	sshkey
	{
		'|1|IzXRLxUoWs2BW7Kbc1GcQWbo8Aw=|cgrlnAJrRifIZmO9H7IImFeSRRs=':
			ensure => present,
			key => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==',
			type => 'ssh-rsa',
			;
		'|1|QQ31zQ2VjPlRsKIbpJCiADEQEL8=|8a7dIIWcYTkJfucRuK6fOs5Ej3o=':
			ensure => present,
			key => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==',
			type => 'ssh-rsa',
			;
	}
}

define git_powered::with_cloned_repo($git_origin, $username, $target_dir, $branch = 'master')
{
	require git_powered # real dependency, OK
	
	# First we set the path for all 'exec' resources in this scope
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
		"$name-cloned-repo-create":
			# user    => $username, no, because $username doesn't always have the rights to create this folder.
			#                       Permissions will be set later, see the directory declaration below
			command => "git clone $git_origin $target_dir",
			creates => $target_dir,
			require => User[$username],
	}
	file
	{
		$target_dir:
			owner   => $username,
			group   => $username,
			#mode    => 664, NO ! No mode, permissions are handled by git (and are seen as modifications if changed)
			recurse => true,
			ensure  => directory,
			require => [ User[$username], Exec["$name-cloned-repo-create"] ]; # because must be created by git clone, not by puppet !
	}
	exec
	{
		"$name-cloned-repo-select-proper-branch":
			user    => $username, # it's OK now.
			group   => $username,
			cwd     => $target_dir,
			command => "git checkout -b $branch origin/$branch",
			unless  => "git branch | grep \" $branch\\>\"",
			require => [ File[$target_dir], Exec["$name-cloned-repo-create"] ],
	}
	file
	{
		"$target_dir/.gitmodules":
			owner   => $username,
			group   => $username,
			ensure  => present,
			require => Exec["$name-cloned-repo-select-proper-branch"],
	}
	exec
	{
		"$name-cloned-repo-init-submodules":
			user        => $username,
			group       => $username,
			cwd         => "$target_dir",
			command     => "git submodule init",
			subscribe   => File["$target_dir/.gitmodules"],
			refreshonly => true;
		"$name-cloned-repo-update-submodules": # XXX how to handle this ? Should run regularly ? Or not ?
			user    => $username,
			group   => $username,
			cwd     => "$target_dir",
			command => "git submodule update --recursive",
			require => Exec["$name-cloned-repo-init-submodules"]
	}
}
