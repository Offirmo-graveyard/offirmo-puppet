
# Ensure that the igraph graph manipulation library is present.

# utility class
# used to be able to specifiy a run stage
class with_igraph_ppa_apt_repository
{
	apt_powered::ppa_apt_repository
	{
		igraph_ppa_apt_repository:
			ppa => "ppa:igraph/ppa";
	}
} # class with_igraph_ppa_apt_repository


class igraph_powered
{
	class
	{
		# we use an utility class to be able to specify the stage
		with_igraph_ppa_apt_repository:
			stage => apt
	}
	
	package
	{
		[ 'libigraph', 'libigraph-dev' ]:
			ensure  => latest;
			# no ppa dependency, stages make it unnecessary
	}
	
} # igraph_powered
