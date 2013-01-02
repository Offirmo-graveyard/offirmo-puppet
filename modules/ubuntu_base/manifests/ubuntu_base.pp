

class ubuntu_base($headless = true)
{
	# First, we check if this class is really applied to a compatible system :
	# First, we check if this class is really applied to a compatible system :
	if $operatingsystem != 'Ubuntu'
	{
		err("It looks like this sytem is not a Ubuntu ($operatingsystem). This class is for ubuntu systems only.")
	}
	else
	{
		## Now we automatically select some other modules according to the environment
		if $is_virtual
		{
			if $virtual == 'vmware'
			{
				class
				{
					'ubuntu_base_vmware':
						headless => $headless,
						;
				}
			}
			elsif $virtual == 'virtualbox'
			{
				class
				{
					'ubuntu_base_virtualbox':
						headless => $headless,
						;
				}
			}
			else
			{
				## unknown virtualization mode
				warning("The virtualization mode of your system is unknown ($virtual). You may want to install drivers and additions.")
			}
		}

		
	} ## is Ubuntu ?
} # class ubuntu_base
