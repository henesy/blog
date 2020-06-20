#include <alef.h>

void
main(void)
{
	int i, arr[10];

	arr[i = 0::10] = i * i;
	print("%d ", arr[0::10]);

	print("\n");
}