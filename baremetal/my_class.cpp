#include "my_class.hpp"

my_class::my_class()
{
	_val = 0x11223344;
}

void my_class::set_val(int val)
{
	_val = val;
}

int my_class::get_val()
{
	return _val;
}
