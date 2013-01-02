
## Working C++ environment

class cpp_powered::params()
{
	include offirmo_ubuntu::params

	if ($cpp_working_dir)
	{ $working_dir = $cpp_working_dir }
	else
	{ $working_dir = "$offirmo_ubuntu::params::root_working_dir/cpp" }
	
	if ($cpp_owner)
	{ $owner = $cpp_owner }
	else
	{ $owner = "$offirmo_ubuntu::params::owner" }
}

# Ensure that the c++ dev tools are present.

class cpp_powered::common()
{
	require cpp_powered::params

	## of course, basis of the basis
	include 'with_tool::build-essential'
	## very useful too
	include 'with_tool::cmake'

	## now dirs
	file
	{
		$cpp_powered::params::working_dir:
			ensure => directory,
			owner  => $cpp_powered::params::owner,
			;
	}
}

class cpp_powered::dev()
{
	class
	{
		'cpp_powered::common':
			;
	}
	
	## add needed dev tools
	package
	{
		'gdb':
			ensure => present, # we'd rather not change version suddenly
			;
		'colormake':
			;
		 # 'gdbserver':
	}

} # class cpp powered::development

class cpp_powered()
{
	class
	{
		'cpp_powered::common':
			;
	}
} # class cpp powered
