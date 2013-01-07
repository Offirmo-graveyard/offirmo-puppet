
## Working ruby environment

class ruby_powered::params()
{
	include offirmo_ubuntu::params

	if ($ruby_working_dir)
	{ $working_dir = $ruby_working_dir }
	else
	{ $working_dir = "$offirmo_ubuntu::params::root_working_dir/ruby" }
	
	if ($ruby_owner)
	{ $owner = $ruby_owner }
	else
	{ $owner = "$offirmo_ubuntu::params::owner" }
}

# Ensure that the c++ dev tools are present.

class ruby_powered::common($rvm_version = 'stable', $rvm_security = 'yes', $ruby_type = 'mri', $ruby_version = '1.9.3')
{
	require ruby_powered::params

	## rvm of course
	class
	{
		'rvm_powered':
			version  => $rvm_version,
			security => $rvm_security,
			;
	}

	## make user rvm-enabled
	rvm_powered::user
	{
		"${ruby_powered::params::owner}-as-rvm-user":
			username => $ruby_powered::params::owner,
			;
	}

	## and install him a ruby
	class
	{
		'rvm_powered::ruby':
			user    => $ruby_powered::params::owner,
			type    => $ruby_type,
			version => $ruby_version,
	}

	## now dev dirs
	file
	{
		$ruby_powered::params::working_dir:
			ensure => directory,
			owner  => $ruby_powered::params::owner,
			;
	}
}


class ruby_powered::dev()
{
	class
	{
		'ruby_powered::common':
			## special dev options
			rvm_version  => 'latest',
			rvm_security => 'no-and-I-really-understand-what-I-do',
			ruby_version => '1.9.3-head'
			;
	}

	## TODO add dev tools

} # class ruby_powered::development


class ruby_powered()
{
	class
	{
		'ruby_powered::common':
			;
	}
} # class ruby_powered
