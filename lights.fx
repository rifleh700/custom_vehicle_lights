
#include "container.fx"

float4 gMaterialAmbient     < string materialState="Ambient"; >;
float4 gMaterialDiffuse     < string materialState="Diffuse"; >;
float4 gMaterialSpecular    < string materialState="Specular"; >;
float4 gMaterialEmissive    < string materialState="Emissive"; >;
float gMaterialSpecPower    < string materialState="Power"; >;

static float M_EPS = 1/256.0;
static float4 WHITE = 1;
static int NOT_LIGHT = -1;

static float3 LIGHTS_FLAGS[MACRO_LIGHTS_FLAGS_ARRAY_SIZE] = {
	MACRO_LIGHTS_FLAGS_ARRAY
};

bool MatchRGB(float3 rgb1, float3 rgb2) {
    return
    	abs(rgb1.r - rgb2.r) < M_EPS &&
    	abs(rgb1.g - rgb2.g) < M_EPS &&
        abs(rgb1.b - rgb2.b) < M_EPS;
}

int DetectLight() {

	int light = NOT_LIGHT;
	bool found = false;
	for(int i = 0; (i < MACRO_LIGHTS_FLAGS_ARRAY_SIZE) && !found; i++) {
		light = i;
		found = MatchRGB(LIGHTS_FLAGS[i]/255, gMaterialDiffuse.rgb);
	}
	return found ? light : NOT_LIGHT;
}
static int CURRENT_LIGHT = DetectLight();


technique lights {
	pass P0 {
		MaterialAmbient = gMaterialAmbient/gMaterialDiffuse;
		MaterialDiffuse = WHITE;
		MaterialPower = gMaterialSpecPower;
		MaterialSpecular = gMaterialSpecular;
		MaterialEmissive = CURRENT_LIGHT != NOT_LIGHT ? GetContainerData(CURRENT_LIGHT) : gMaterialEmissive;
	}
}

technique fallback {
	pass P0 {
	}
}