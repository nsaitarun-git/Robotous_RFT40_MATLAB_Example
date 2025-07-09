# Matlab code for Robotous RFT40 Force/Torque Sensor
## Prerequisites
Matlab 2024a or above. Previous versions of Matlab that support ```serialport``` objects may also work with this code.

## Functions
-[sendCommand] - Send command to the sensor using the predefined hexadecimal commands.
-[readResponse] - Read the response from the sensor when it matches the expected response ID.
-[commandSetOutputRate] -  Set the data rate of the sensor from the available options.
-[hardTare] -  Onboard zero tare of force and torque data.
-[softTare] - Software level zero tare of force and torque data.
-[bytesCallback] - Callback function executes whenever 19 bytes of data are available in the serial buffer. The data bytes are converted to force and torque values, which are converted and stored in ```s.UserData```.
