// simple bencmark for cpu core, abi, memory random access & compiler performance

// Setup for the test if longer runtimes are needed
#define NUM_ROUNDS         8
#define MAX_RECURSE        4
#define ARRAY_SIZE         16
#define ARRAY_SIZE_MASK    0x0f

typedef struct {
	int call_counter;
	unsigned char array8[ARRAY_SIZE];
	unsigned int array32[ARRAY_SIZE];
} alintstone_t;

alintstone_t __data;

void __alintstone_init(alintstone_t *__data)
{
	for(int i=0; i < ARRAY_SIZE; i++) {
		__data->array8[i] = 0;
		__data->array32[i] = 0;
	}
}

int __alintstone_recurse(int level, alintstone_t *__data, int counter, int counter2)
{
	__data->call_counter++;
	
	if(level > MAX_RECURSE)
		return counter;
	
	for(int i=0; i < ARRAY_SIZE; i++) {
		__data->array8[i] += counter2 + __data->array8[(i+ARRAY_SIZE/4) & ARRAY_SIZE_MASK];
		counter2++;
	}

	for(int i=0; i < ARRAY_SIZE; i++) {
		counter += __alintstone_recurse(level+1, __data, counter, counter2);
		__data->array32[i] += __data->array8[i] + counter;
		counter2 += __data->array32[(i+ARRAY_SIZE/4) & ARRAY_SIZE_MASK];
	}
	return counter + counter2;
}

int alintstone(void)
{
	int ret;
	__data.call_counter = 0x0;
	
	__alintstone_init(&__data);
	
	for(int i=0; i<NUM_ROUNDS; i++) {
		ret += __alintstone_recurse(1, &__data, 0, i);
	}
	
	return __data.call_counter;
}