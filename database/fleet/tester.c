#include "tester.h"

/*
 * this code simulates how user would use our service
 */


void main()
{
	t_data data;

	t_data *result;

	__getData__(&data);

	__computate__ (&data, __kernel__, result);

	__verify(&data, __kernel__, result);
}

