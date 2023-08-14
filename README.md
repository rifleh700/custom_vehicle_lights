## Description
This is MTA:SA custom vehicles lights system resource. It allows you to create any lights you want (break, reverse, indicators, sirens, etc, concrete name doesnt matter) and manage they. It is based on simple shader (for brighting light textures) and custom coronas (for emulating light effect).

The resource provides only client-side lights API. For ready to use lights system see [improved_vehicle_lights](https://github.com/rifleh700/improved_vehicle_lights "improved_vehicle_lights") resource.

[Demo video here!](https://imgur.com/0DygyZf "Demo video here!")

## Features
- One shader per vehicle
- Single light texture (or you can use more if you need)
- Up to 48 lights per vehicle (technically it can be extended in future)
- Flexible configuration
- Non-discrete light power (from 0 to 1)

## Requirements
The resource uses custom directional coronas to emmulate light effect. So it requires [extended_custom_coronas](https://github.com/rifleh700/extended_custom_coronas "extended_custom_coronas") resource (it is modified version of custom_coronas resource by Ren712 - thx him for coronas).

## Exported client-side functions
- `float getVehicleCustomLightPower(element vehicle, string lightName)`
- `boolean setVehicleCustomLightPower(element vehicle, string lightName, float power)` (power is from 0.0 to 1.0)
- `float getVehicleCustomLightSize(element vehicle, string lightName)`
- `boolean setVehicleCustomLightSize(element vehicle, string lightName, float size)`
- `int, int, int, int getVehicleCustomLightColor(element vehicle, string lightName)`
- `boolean setVehicleCustomLightColor(element vehicle, string lightName, int r, int g, int b, int a)`

## How to use
### Lights config
Firstly look at `cvl_config.xml`. Here is lights properties. Use it as is or change it as you want.

The "textures" node tells what textures will be used for lights:
- `name` name of the texture

The "lights" node defines custom lights:
- `name` unique name of the light (used in functions)
- `flag` material diffuse rgb value of the texture
- `dummy` vehicle dummy name, used for custom corona
- `size` size of custom corona
- `color` color of custom corona
- `mirrrored` use it if u want to mirror dummy position (it's usually used for left-side lights)

The "models" block has the lights unique settings for concrete vehicle models. For example, some models might have red indicators.
- `name` name of the customizable light (must be defined in global "lights" node)
- `size` size of custom corona
- `color` color of custom corona
- `rotation` rotation of custom corona (it is recommended to define light rotation by model dummies, not by this config)


### Model adaptation
Steps by example of `reverse_r` light:
- create material with texture named `vehiclelights` (this is just default name, you can change it or add another in config)
- define material diffuse color equals to `flag` value, for `reverse_r` it is `255,58,1`
- apply material to light polygons
- create unique dummy named `reverselights` and define its rotation (remember that ZModeller has wrong axis, check any "ImVehFt" vehicle model, or just add additional dummy with suffix `_dir`, for example `reverselights_dir`, which means light direction vector)
- done

**Note: if you works with ZModeller, remember that DFF importing resets all diffuse colors! Work with ZModeler project files.**

![](https://i.imgur.com/NT8Vda2.png)
