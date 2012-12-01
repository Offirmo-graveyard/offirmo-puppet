
# Java




class java_powered($version = '6', $provider = 'sun')
{
	
	if ($provider == 'sun' and $version == '6')
	{
		package
		{
			[ 'sun-java6-jre' ]:
				require      => File["/var/cache/debconf/jre6.seeds"],
				responsefile => "/var/cache/debconf/jre6.seeds",
				ensure => present;
		}
		
		file
		{
			'/var/cache/debconf/jre6.seeds':
			source => "puppet:///modules/java_powered/jre6.seeds",
			ensure => present;
		}
	}
	else
	{
		fail()
	}
}



class java_powered::development($version = '6', $provider = 'sun')
{
	fail()
#, sun-java6-jdk, sun-java6-bin
}
