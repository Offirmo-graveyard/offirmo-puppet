
## Working shell environment

class shell_powered::params()
{
	include offirmo_ubuntu::params

	if ($shell_working_dir)
	{ $working_dir = $shell_working_dir }
	else
	{ $working_dir = "$offirmo_ubuntu::params::root_working_dir/shell" }
	
	if ($shell_owner)
	{ $owner = $shell_owner }
	else
	{ $owner = "$offirmo_ubuntu::params::owner" }
}

# Ensure that the c++ dev tools are present.

class shell_powered::common()
{
	require shell_powered::params

	require with_tool::bash

	## now dirs
	file
	{
		$shell_powered::params::working_dir:
			ensure => directory,
			owner  => $shell_powered::params::owner,
			;
	}
}

class shell_powered::dev()
{
	class
	{
		'shell_powered::common':
			;
	}

	## TODO add dev tools

} # class shell_powered::development

class shell_powered()
{
	class
	{
		'shell_powered::common':
			;
	}
} # class shell_powered
