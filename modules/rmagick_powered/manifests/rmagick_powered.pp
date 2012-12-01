
# Ensure that the rmagick image manipulation library is present.

class rmagick_powered
{
	package
	{
		[ 'libmagickcore-dev', 'libmagickwand-dev' ]:
			ensure => present;
	} # package
	
} # class rmagick_powered
