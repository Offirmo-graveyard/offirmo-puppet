
# Ensure that the git source control tool is present.

class svn_powered
{
	package
	{
		'subversion':
			ensure => present; # this package is critical and updates should be supervised. We don't use 'latest'.
	} # package
	
}

