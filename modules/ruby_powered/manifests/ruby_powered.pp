
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

class ruby_powered::common($rvm_version = 'stable', $rvm_security = 'yes', ruby = 'mri', ruby_version = '1.9.3')
{
	require ruby_powered::params

	## of course
	class
	{
		'rvm_powered':
			version  => $rvm_version,
			security => $rvm_security,
			;
	}

	## now dirs
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
