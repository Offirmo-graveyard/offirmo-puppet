
# This class describes a web server able to serve several wordpress (not multi-site).

# creates the wordpress database with an associated user
# creates a dedicated linux user for security (not finished yet)
# deploy a pre-configured wordpress (with several plugins)

class smtp_server::params
{
	
}

class smtp_server()
{
	include smtp_server::params

	package
	{
		[ 'postfix' ]:
			ensure => latest; # This packages is critical for security, we must use 'latest'
	}
	
} # class smtp_server

