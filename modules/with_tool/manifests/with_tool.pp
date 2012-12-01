

# We don't need bleeding edge. 'present' is enough.
# This package is very well tested, we can use 'latest'
# This packages is not critical, we can use 'latest'

class with_tool::bash
{
	package
	{
		'bash':
			ensure => latest; # This package is very well tested, we can use 'latest'
	}
}

class with_tool::curl
{
	package
	{
		'curl':
			ensure => latest; # This packages is not critical, we can use 'latest'
	}
}

class with_tool::whois
{
	package
	{
		'whois':
			ensure => latest; # This packages is not critical, we can use 'latest'
	}
}

class with_tool::build-essential
{
	package
	{
		'build-essential':
			ensure => latest; # This package is very well tested, we can use 'latest'
	}
}

class with_tool::linux-source
{
	package
	{
		'linux-source':
			ensure => latest; # This package *must* be 'latest'
	}
}

class with_tool::linux-headers-virtual
{
	package
	{
		'linux-headers-virtual':
			ensure => latest; # This package *must* be 'latest'
	}
}

class with_tool::python-software-properties
{
	package
	{
		'python-software-properties': 
			ensure => latest # This packages is not critical, we can use 'latest'
	}
}

class with_tool::wget
{
	package
	{
		'wget':
			ensure => latest; # This packages is not critical, we can use 'latest'
	}
}

class with_tool::patch
{
	package
	{
		'patch':
			ensure => latest; # This packages is not critical, we can use 'latest'
	}
}

class with_tool::cmake
{
	package
	{
		['cmake', 'cmake-curses-gui' ]:
			ensure => latest; # Those packages are not critical, we can use 'latest' (really ?)
	}
}
