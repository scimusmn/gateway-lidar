An exhibit to demonstrate LIDAR with the TeraRanger One ToF sensor.

The Arduino grabs data from the TeraRanger One via I2C and transmits it over serial in the format `{[trimpot value],[distance reading]}`. The Processing sketch provides a visualization of the local 2D environment based on this data.