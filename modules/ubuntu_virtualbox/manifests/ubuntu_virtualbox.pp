

class ubuntu_virtualbox($headless = true)
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
		
		# Now we'll install the VMware tools, needed for better perfs and additional functionalities
		# VMware tools provided by VMware cannot be installed on modern distros.
		# We'll use community maintained open-vm-tools (with the blessing of VMware)
		# Explanations : https://help.ubuntu.com/community/VMware/Tools 
		
		# very important ! The package will install differently according to the presence of those packages,
		# so they MUST be present before apt-get install
		require with_tool::build-essential
		require with_tool::linux-source
		require with_tool::linux-headers-virtual
		
		# ...
	
	} # check if virtualbox virtualized
} # class ubuntu_virtualbox
