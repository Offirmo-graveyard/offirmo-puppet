

class ubuntu_base_virtualbox($headless = true)
{
	# First, we check if this class is really applied to a compatible system :
	if !$is_virtual
	{
		err("It looks like this sytem is not virtualized. This class is for virtualbox virtualized systems only.")
	}
	elsif $virtual != 'virtualbox'
	{
		err("It looks like this sytem is not a virtualbox virtual machine (virtual = $virtual). This class is for virtualbox virtualized systems only.")
	}
	else
	{
		# OK, can proceed
		# Here we set the path for all 'exec' resources in this scope.
		Exec {
			path => [
					'/usr/local/bin',
					'/opt/local/bin',
					'/usr/bin',
					'/usr/sbin',
					'/bin',
					'/sbin' ],
			logoutput => true,
		}
		
		## Those packages are needed for VirtualBox additions
		require with_tool::build-essential
		require with_tool::linux-source
		require with_tool::linux-headers-virtual
		
		## I don't know how to install VirtualBox additions automatically...
	
	} # check if virtualbox virtualized
} # class ubuntu_virtualbox
