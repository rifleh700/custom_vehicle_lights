
static int FLOAT_SIZE = 32;
static int FLOAT_CAPACITY = (FLOAT_SIZE-1)/8;

int sDataContainer1[16];

float GetContainerData(int index) {

	int containerIndex = index / FLOAT_CAPACITY;
	int floatIndex = index % FLOAT_CAPACITY;
	
	int intItems[] = {0, 0, 0};
	float containerInt = sDataContainer1[containerIndex];
    intItems[2] = floor(containerInt / 256.0 / 256.0);
    intItems[1] = floor((containerInt - intItems[2] * 256.0 * 256.0) / 256.0);
    intItems[0] = floor(containerInt - intItems[2] * 256.0 * 256.0 - intItems[1] * 256.0);
    
    return intItems[floatIndex]/255.0;
};