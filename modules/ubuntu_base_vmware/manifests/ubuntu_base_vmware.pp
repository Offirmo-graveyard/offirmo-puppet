

class ubuntu_base_vmware($headless = true)
{
	# First, we check if this class is really applied to a compatible system :
	if !$is_virtual
	{
		err("It looks like this sytem is not virtualized. This class is for vmware virtualized systems only.")
	}
	elsif $virtual != 'vmware'
	{
		err("It looks like this sytem is not a vmware virtual machine (virtual = $virtual). This class is for vmware virtualized systems only.")
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
		
		# very important ! The VMware tools package will install differently according to the presence of those packages,
		# so they MUST be present before apt-get install
		require with_tool::build-essential
		require with_tool::linux-source
		require with_tool::linux-headers-virtual
		
		# here we use 'exec' instead of 'package'
		# because I haven't found how to pass '--no-install-recommends' via the 'package' resource type.
		# It's OK because this command can be run multiple times without risks.
		exec {
			'install-open-vm-dkms':
				command => 'sudo apt-get install --no-install-recommends open-vm-dkms --yes',
				require => Package['build-essential', 'linux-source', 'linux-headers-virtual'];
			'install-open-vm-tools':
				# depending if we want an 'headless' vm or not, we use a different command
				command => $headless ? {
					false   => 'sudo apt-get install open-vm-tools --yes',
					default => 'sudo apt-get install --no-install-recommends open-vm-tools --yes',
				},
				require => Package['build-essential', 'linux-source', 'linux-headers-virtual'];
		}
		
		# open-vm-toolbox
		
		
		puppet_powered::impossible_class
		{
			"install-vmware-optimized-network-driver":
				text => "
I can't manage to automatically install the vmware network driver
because it temporarily disrupt the network and thus may stop puppet client/server operation.

Note : vmware tools must be installed.

WARNING ! This manipulation will temporarily disrupt the network of your virtual machine.
So, of course, do NOT do it via ssh or telnet ! You *must* have a local access.

What to do :
	
	# stop networking
	sudo /etc/init.d/networking stop
	
	# remove non-optimized driver
	sudo rmmod pcnet32
	
	# install optimized driver
	sudo modprobe vmxnet
	
	# restart networking
	sudo /etc/init.d/networking start

",
			;
		} # puppet_powered::impossible_class
	
	} # check if vmware virtualized
} # class ubuntu_vmware
