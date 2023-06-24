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
- `string getVehicleCustomLightName(number lightID)` get custom light name by its ID
- `number getVehicleCustomLightFromName(string name)` get custom light ID by its name
- `number getVehicleCustomLightPower(element vehicle, number lightID)` get vehicle custom light current power (float value from 0 to 1)
- `boolean setVehicleCustomLightPower(element vehicle, number lightID, number power)` set vehicle custom light power (float value from 0 to 1)

## How to use
### Lights config
Firstly look at `config.xml`. Here is lights properties. Use it as is or change it as you want.

Texture item tells what textures will be used for lights:
- `name` name of the texture

Light item means concrete custom light:
- `name` unique name of the light (used in functions)
- `flag` material diffuse rgb value of the texture
- `dummy` vehicle dummy name, used for custom corona
- `size` size of custom corona
- `color` color of custom corona
- `mirrrored` use it if u want to mirror dummy position (it's usually used for left-side lights)

### Model adaptation
Steps by example of `reverse_r` light:
- create material with texture named `vehiclelights` (this is just default name, you can change it or add another in config)
- define material diffuse color equals to `flag` value, for `reverse_r` it is `255,58,1`
- apply material to light polygons
- create unique dummy named `reverselights` and define its rotation
- done

**Note: if you works with ZModeller, remember that DFF importing resets all diffuse colors! Work with ZModeler project files.**

![](https://i.imgur.com/NT8Vda2.png)
