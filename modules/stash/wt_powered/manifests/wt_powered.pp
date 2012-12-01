
# This class represents a zend server CE = apache bundled by the Zend company
# I use this one instead of a raw apache because Zend bundle a web interface for status and logs

class with_Pau_Garcia_i_Quiles_wt_ppa_apt_repository
{
	apt_powered::ppa_apt_repository
	{
		igraph_ppa_apt_repository:
			ppa => "ppa:pgquiles/wt";
	}
	
	# https://launchpad.net/~pgquiles/+archive/wt/+packages
	
	# libwt-common  C++ library and application server for web applications [common]
    # libwt-dbg     C++ library and application server for web applications [debug]
    # libwt-dev     C++ library and application server for web applications [development]
    # libwt-doc     C++ library and application server for web applications [doc]
    # libwt29       C++ library and application server for web applications [runtime]
	
    # libwtdbo-dev  Wt::Dbo ORM library for Wt [development]
    # libwtdbo29    Wt::Dbo ORM library for Wt [runtime]
    # libwtdbopostgres-dev   PostgreSQL backend for Wt::Dbo [development]
    # libwtdbopostgres29     PostgreSQL backend for Wt::Dbo [runtime]
    # libwtdbosqlite-dev     sqlite3 backend for Wt::Dbo [development]
    # libwtdbosqlite29       sqlite3 backend for Wt::Dbo [runtime]
	
    # libwtext-dev     additional widgets for Wt, based on ExtJS 2.0.x [development]
    # libwtext29       additional widgets for Wt, based on ExtJS 2.0.x [runtime]
    # libwtfcgi-dev    FastCGI connector library for Wt [development]
    # libwtfcgi29      FastCGI connector library for Wt [runtime]
    # libwthttp-dev    HTTP(S) connector library for Wt [development]
    # libwthttp29      HTTP(S) connector library for Wt [runtime]
	
    # witty            C++ library for webapps [runtime] (transition package)
    # witty-dbg        C++ library for webapps [debug] (transition package)
    # witty-dev        C++ library for webapps [devel] (transition package)
    # witty-doc        C++ library for webapps [doc] (transition package)
    # witty-examples   C++ library for webapps [examples]
}



class wt_powered::common
{
	require with_tool::build-essential
	
	class
	{
		with_Pau_Garcia_i_Quiles_wt_ppa_apt_repository:
			stage => apt;
	}
	
	package
	{
		#['libwt24', 'libwthttp24', 'libwtext24']:
		['witty']:
			ensure => latest, # usually used for testing, latest is OK
			;
	}
	
} # class wt_powered



class wt_powered::production
{
	include wt_powered::common
}



class wt_powered::development
{
	package
	{
		['witty-dbg', 'witty-dev']:
			ensure => latest, # usually used for testing, latest is OK
			;
	}
	
	include wt_powered::common
}
