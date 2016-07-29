//
// - Read a sensor's current value with sensorValue().
//   For example, to get the current value of the first sensor, use:
//    sensorValue(0)
//   Values are in the range [0.0 .. 1.0].
//
// - Read a sensor's previous value with previousSensorValue().
//   For example, to get the previous value of the first sensor, use:
//    previousSensorValue(0)
//   Values are in the range [0.0 .. 1.0].


// Helper functions for retrieving capacitive sensor values and making sense of them.


// + Whether sensors are present {{{

boolean sensorIsPresent(int i_sensorNo)
// Check whether a particular sensor is connected and present.
//
// Params:
//  i_sensorNo:
//   Which sensor to check for the presence of.
//
// Returns:
//  true: This sensor is present.
//  false: This sensor is not present.
{
    return g_capacitiveSensors_active[i_sensorNo];
}

// + }}}

// + Current value {{{

float sensorNormalizedUnboundedValue(int i_sensorNo)
// Get the current value of a sensor, normalized but unbounded.
//
// "Normalized" means that the value has gone through all its processing (smoothing, stretching)
// and is now converted to the range [0.0 .. 1.0], where 0.0 means there is nobody near the sensor,
// and 1.0 corresponds to the point of zero distance, when a person makes contact with the sensor.
//
// However, in an effect that comes from the nature of the capacitive sensor, when a person comes
// and then makes contact the value will not actually stop at 1.0 exactly but shoot up to a much, much
// higher number (possibly in the hundreds, or thousands, depending on how things are configured).
// This function being "unbounded" means that you will get that inflated value, if the sensor is touched.
// (If you want a reading that is strictly in the range [0.0 .. 1.0], see sensorNormalizedValue()).
//
// Params:
//  i_sensorNo:
//   Which sensor to get the current value of.
//   This is a number in the range [0 .. 5].
//
// Returns:
//  The current value of the sensor.
//  This is a positive number,
//  where 0.0 means there is nobody near the sensor,
//  and 1.0 logically corresponds to the exact point where the sensor is being touched
//  but in reality the if the sensor is being touched then the value will be much higher.
{
    return g_capacitiveSensors_normalizedValues_current[i_sensorNo];
}

float sensorUnboundedValue(int i_sensorNo)
// A short name for sensorNormalizedUnboundedValue().
{
    return sensorNormalizedUnboundedValue(i_sensorNo);
}

float sensorNormalizedValue(int i_sensorNo)
// Get the current value of a sensor, normalized.
//
// "Normalized" means that the value has gone through all its processing (smoothing, stretching)
// and is now converted to the range [0.0 .. 1.0].
//
// This function bounds the value so that if the sensor is being touched, you will actually get 1.0,
// instead of the unpredictably high number that is returned by sensorNormalizedUnboundedValue().
//
// Params:
//  i_sensorNo:
//   Which sensor to get the current value of.
//   This is a number in the range [0 .. 5].
//
// Returns:
//  The current value of the sensor.
//  This is a number in the range [0.0 .. 1.0],
//  where 0.0 means there is nobody near the sensor, and 1.0 means the sensor is being touched.
{
    return clamp(sensorNormalizedUnboundedValue(i_sensorNo), 0.0, 1.0);
}

float sensorValue(int i_sensorNo)
// A short name for sensorNormalizedValue().
{
    return sensorNormalizedValue(i_sensorNo);
}

// + }}}

// + Previous value {{{

float previousSensorNormalizedUnboundedValue(int i_sensorNo)
// Get the previous value of a sensor, normalized but unbounded.
//
// See the comments under sensorNormalizedUnboundedValue() and sensorNormalizedValue()
// for details about the meaning of "normalized" and "unbounded".
//
// Params:
//  i_sensorNo:
//   Which sensor to get the previous value of.
//   This is a number in the range [0 .. 5].
//
// Returns:
//  The current value of the sensor.
//  This is a positive number,
//  where 0.0 means there is nobody near the sensor,
//  and 1.0 logically corresponds to the exact point where the sensor is being touched
//  but in reality the if the sensor is being touched then the value will be much higher.
{
    return g_capacitiveSensors_normalizedValues_previous[i_sensorNo];
}

float previousSensorUnboundedValue(int i_sensorNo)
// A short name for previousSensorNormalizedUnboundedValue().
{
    return previousSensorNormalizedUnboundedValue(i_sensorNo);
}

float previousSensorNormalizedValue(int i_sensorNo)
// Get the previous value of a sensor.
//
// "Normalized" means that the value has gone through all its processing (smoothing, stretching)
// and is now converted to the range [0.0 .. 1.0].
//
// This function bounds the value so that if the sensor is being touched, you will actually get 1.0,
// instead of the unpredictably high number that is returned by sensorNormalizedUnboundedValue().
//
// Params:
//  i_sensorNo:
//   Which sensor to get the previous value of.
//   This is a number in the range [0 .. 5].
//
// Returns:
//  The previous value of the sensor.
//  This is a number in the range [0.0 .. 1.0],
//  where 0.0 means there is nobody near the sensor, and 1.0 means the sensor is being touched.
{
    return clamp(previousSensorNormalizedUnboundedValue(i_sensorNo), 0.0, 1.0);
}

float previousSensorValue(int i_sensorNo)
// A short name for previousSensorNormalizedValue().
{
    return previousSensorNormalizedValue(i_sensorNo);
}

// + }}}

// + Touch state {{{

boolean sensorHeld(int i_sensorNo)
// Tell whether a sensor is currently being touched.
//
// Params:
//  i_sensorNo:
//   The sensor to check.
//
// Returns:
//  true:
//   The sensor is currently being touched.
//  false:
//   The sensor is not currently being touched.
{
    return g_capacitiveSensors_touchStates_current[i_sensorNo];
}

boolean sensorTouched(int i_sensorNo)
// Check whether a sensor has just now been touched.
//
// Params:
//  i_sensorNo:
//   The sensor to check.
//
// Returns:
//  true:
//   In the previous sensor reading, the sensor was not being touched,
//   but according to the current sensor reading, it now is.
//  false:
//   The sensor is either not being touched,
//   or it was already touched sometime previous to the current sensor reading and now only
//   continues to be held down.
{
    return g_capacitiveSensors_touchStates_current[i_sensorNo] &&
        !g_capacitiveSensors_touchStates_previous[i_sensorNo];
}

boolean sensorReleased(int i_sensorNo)
// Check whether a sensor has just now been released.
//
// Params:
//  i_sensorNo:
//   The sensor to check.
//
// Returns:
//  true:
//   In the previous sensor reading, the sensor was being touched,
//   but according to the current sensor reading, it now is not.
//  false:
//   The sensor is either being touched,
//   or it was already untouched sometime previous to the current sensor reading and now only
//   continues to be untouched.
{
    return !g_capacitiveSensors_touchStates_current[i_sensorNo] &&
        g_capacitiveSensors_touchStates_previous[i_sensorNo];
}

// + }}}

// + Rapid increase and decrease in value {{{

boolean sensorValueIncreasedRapidly(int i_sensorNo)
// Detect a sharp increase in a sensor's value.
//
// For a capacitive sensor, typically this signifies that it has just been touched.
//
// Params:
//  i_sensorNo:
//   The sensor to detect the sharp increase in.
//
// Returns:
//  true:
//   The sensor sharply increased in value just now.
//  false:
//   The sensor did not sharply increase in value just now.
//
// Example:
//  if (sensorValueIncreasedRapidly(0))
//  {
//      // ... if we get here then sensor 0 has probably just been touched
//  }
{
    return g_capacitiveSensors_normalizedValues_current[i_sensorNo] -
        g_capacitiveSensors_normalizedValues_previous[i_sensorNo]
        > 0.15;
}

boolean sensorValueDecreasedRapidly(int i_sensorNo)
// Detect a sharp decrease in a sensor's value.
//
// For a capacitive sensor, typically this signifies that it has just been released.
//
// Params:
//  i_sensorNo:
//   The sensor to detect the sharp decrease in.
//
// Returns:
//  true:
//   The sensor sharply decreased in value just now.
//  false:
//   The sensor did not sharply decrease in value just now.
//
// Example:
//  if (sensorValueDecreasedRapidly(0))
//  {
//      // ... if we get here then sensor 0 has probably just been released
//  }
{
    return g_capacitiveSensors_normalizedValues_current[i_sensorNo] -
        g_capacitiveSensors_normalizedValues_previous[i_sensorNo]
        < -0.15;
}

// + }}}

boolean sensorValueGoneHigh(int i_sensorNo)
// Detect a sharp increase in a sensor's value.
//
// For a capacitive sensor, typically this signifies that it has just been touched.
//
// Params:
//  i_sensorNo:
//   The sensor to detect the sharp increase in.
//
// Returns:
//  true:
//   The sensor sharply increased in value just now.
//  false:
//   The sensor did not sharply increase in value just now.
//
// Example:
//  if (sensorValueIncreasedRapidly(0))
//  {
//      // ... if we get here then sensor 0 has probably just been touched
//  }
{
    boolean rv =
        g_capacitiveSensors_normalizedValues_previous[i_sensorNo] <= 0.5 &&
        g_capacitiveSensors_normalizedValues_current[i_sensorNo] > 0.5;
    return rv;
}

/*
float getCapacitiveSensorMinimumValue(int i_sensorNo)
{
    if (g_capacitiveSensors_smoothedValues_minimums[i_sensorNo] == Float.MAX_VALUE &&
        g_capacitiveSensors_smoothedValues_maximums[i_sensorNo] == Float.MIN_VALUE)
        return 0.0;

    return g_capacitiveSensors_smoothedValues_minimums[i_sensorNo];
}

float getCapacitiveSensorMaximumValue(int i_sensorNo)
{
    if (g_capacitiveSensors_smoothedValues_minimums[i_sensorNo] == Float.MAX_VALUE &&
        g_capacitiveSensors_smoothedValues_maximums[i_sensorNo] == Float.MIN_VALUE)
        return 0.0;

    return g_capacitiveSensors_smoothedValues_maximums[i_sensorNo];
}
*/

//
// maybe TODO
//  sensorRawValue()
//  sensorFlattenedValue()
//  sensorSmoothedValue()
//  sensorNormalizedValue()
//   (already an alias for sensorValue())
