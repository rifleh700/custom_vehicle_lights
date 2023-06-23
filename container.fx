
static int FLOAT_SIZE = 32;
static int FLOAT_CAPACITY = (FLOAT_SIZE-1)/8;

int sDataContainer1[16];

float GetContainerData(int index) {

	int containerIndex = index / FLOAT_CAPACITY;
	int floatIndex = index % FLOAT_CAPACITY;
	
	int intItems[] = {0, 0, 0};
	int containerInt = sDataContainer1[containerIndex];
	
	intItems[2] = (containerInt) / 65536;
    intItems[1] = (containerInt - intItems[2] * 65536) / 256;
    intItems[0] = (containerInt - intItems[2] * 65536 - intItems[1] * 256);

    return intItems[floatIndex]/255.0;
};