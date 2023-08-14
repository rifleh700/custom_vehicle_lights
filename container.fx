
//Stores data as int
int sDataContainer1[16];

//Returns data as float
float GetContainerData(int index) {

	int containerIndex = index / 3;
	int intIndex = index % 3;
	
	int ints[] = {0, 0, 0};
	int data = sDataContainer1[containerIndex];

	ints[2] = (data) / 65536;
	data %= 65536;
    ints[1] = data / 256;
    data %= 256;
    ints[0] = data;

    return ints[intIndex]/255.0;
};