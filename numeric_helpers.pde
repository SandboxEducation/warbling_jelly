
// + Logarithms {{{

float logN(float i_base, float i_value)
// Logarithm to an arbitrary base.
//
// Params:
//  i_base:
//   Must be > 0.
//  i_value:
//   Must be > 0.
{
    return log(i_value) / log(i_base);
}

// + }}}

// + Clamping {{{

float clamp(float i_value,
            float i_rangeStart, float i_rangeEnd)
// Params:
//  i_value:
//   (number)
//  i_rangeStart:
//   (number)
//   Minimum allowed value.
//  i_rangeEnd:
//   (number)
//   Maximum allowed value.
//
// Returns:
//  (number)
{
    if (i_value < i_rangeStart)
        return i_rangeStart;
    if (i_value > i_rangeEnd)
        return i_rangeEnd;
    return i_value;
};

// + }}}

// + Map values between linear and exponential ranges {{{

float mapLinToLin(float i_value,
                  float i_fromStart, float i_fromEnd,
                  float i_toStart, float i_toEnd)
{
    //print("mapLinToLin(" + i_value + ", " + i_fromStart + ", " + i_fromEnd + ", " + i_toStart + ", " + i_toEnd + ")");

    float rv = (i_value - i_fromStart) * (i_toEnd - i_toStart) / (i_fromEnd - i_fromStart) + i_toStart;

    // Suppress NaN,
    // which probably happened because i_fromStart == i_fromEnd
    if (Float.isNaN(rv))
        rv = i_toStart;

    // Suppress infinities,
    // which can result from eg. mapLinToLin(0.0, 3.4028235E38, 1.4E-45, 1700.0, 2300.0) = Infinity
    if (rv == Float.NEGATIVE_INFINITY || rv == Float.POSITIVE_INFINITY)
        rv = 0.0;

    //println(" = " + rv);
    return rv;
}

float newMapLinToExp(float i_value,
                     float i_base,
                     float i_fromStart, float i_fromEnd,
                     float i_toStart, float i_toEnd)
// Params:
//  i_base:
//   In earlier, less flexible versions of this function, this was fixed to i_toEnd / i_toStart.
{
    // i_value range is [i_fromStart .. i_fromEnd]
    i_value = (i_value - i_fromStart) / (i_fromEnd - i_fromStart);
    // i_value range is [0 .. 1]
    i_value = pow(i_base, i_value);
    // i_value range is [1 .. base]
    i_value -= 1;
    // i_value range is [0 .. base-1]
    i_value /= i_base - 1;
    // i_value range is [0 .. 1]
    i_value = i_value * (i_toEnd - i_toStart) + i_toStart;
    // i_value range is [i_toStart .. i_toEnd]

    /* Above code without temporaries
    i_value = (((pow(i_base,
                     (i_value - i_fromStart) / (i_fromEnd - i_fromStart)))
                - 1)
               / (i_base - 1))
        * (i_toEnd - i_toStart) + i_toStart;
    */

    // Suppress NaN
    if (Float.isNaN(i_value))
        i_value = i_toStart;

    // Suppress infinities
    if (i_value == Float.NEGATIVE_INFINITY || i_value == Float.POSITIVE_INFINITY)
        i_value = 0.0;

    return i_value;
}
/*
float newMapLinToExp(float i_value,
                     float i_power,
                     float i_fromStart, float i_fromEnd,
                     float i_toStart, float i_toEnd)
// Params:
//  i_power:
//   In earlier, less flexible versions of this function, this was fixed to i_toEnd / i_toStart.
{
    // i_value range is [i_fromStart .. i_fromEnd]
    i_value = (i_value - i_fromStart) / (i_fromEnd - i_fromStart);
    // i_value range is [0 .. 1]
    i_value = pow(i_value, i_power);
    // i_value range is [0 .. power]
    i_value /= i_power;
    // i_value range is [0 .. 1]
    i_value = i_value * (i_toEnd - i_toStart) + i_toStart;
    // i_value range is [i_toStart .. i_toEnd]

    // Suppress NaN
    if (Float.isNaN(i_value))
        i_value = i_toStart;

    // Suppress infinities
    if (i_value == Float.NEGATIVE_INFINITY || i_value == Float.POSITIVE_INFINITY)
        i_value = 0.0;

    return i_value;
}
*/

float newMapExpToLin(float i_value,
                     float i_base,
                     float i_fromStart, float i_fromEnd,
                     float i_toStart, float i_toEnd)
// Params:
//  i_base:
//   In earlier, less flexible versions of this function, this was fixed to i_fromEnd / i_fromStart.
//   Must be > 0.
{
    //print("newMapExpToLin(" + i_base + ", " + i_value + ", " + i_fromStart + ", " + i_fromEnd + ", " + i_toStart + ", " + i_toEnd + ")");

    // i_value range is [i_fromStart .. i_fromEnd]
    i_value = (i_value - i_fromStart) / (i_fromEnd - i_fromStart);
    // i_value range is [0 .. 1]
    i_value *= i_base - 1;
    // i_value range is [0 .. base-1]
    i_value += 1;
    // i_value range is [1 .. base]
    i_value = logN(i_base, i_value);
    // i_value range is [0 .. 1]
    i_value = i_value * (i_toEnd - i_toStart) + i_toStart;
    // i_value range is [i_toStart .. i_toEnd]

    /* Above code without temporaries
    i_value = logN(i_base,
                   ((i_value - i_fromStart) / (i_fromEnd - i_fromStart)
                    * i_base - 1)
                   + 1)
        * (i_toEnd - i_toStart) + i_toStart;
    */

    // Suppress NaN
    if (Float.isNaN(i_value))
        i_value = i_toStart;
    
    // Suppress infinities
    if (i_value == Float.NEGATIVE_INFINITY || i_value == Float.POSITIVE_INFINITY)
        i_value = 0.0;

    //println(" = " + i_value);
    return i_value;
}


/*
gnuplot tests

logN(i_base, i_value) = log(i_value) / log(i_base)
pow(b, v) = b**v

newMapLinToExpNoTemps(i_value, \
                      i_base, \
                      i_fromStart, i_fromEnd, \
                      i_toStart, i_toEnd) = \
    (((pow(i_base, \
           (i_value - i_fromStart) / (i_fromEnd - i_fromStart))) \
      - 1) \
     / (i_base - 1)) \
 * (i_toEnd - i_toStart) + i_toStart

newMapExpToLinNoTemps(i_value, \
                      i_base, \
                      i_fromStart, i_fromEnd, \
                      i_toStart, i_toEnd) = \
     logN(i_base, \
          ((i_value - i_fromStart) / (i_fromEnd - i_fromStart) \
           * (i_base - 1)) \
          + 1) \
  * (i_toEnd - i_toStart) + i_toStart


print newMapLinToExpNoTemps(20.0, 10.0, 20.0, 200.0, 300.0, 6000.0)
print newMapLinToExpNoTemps(200.0, 10.0, 20.0, 200.0, 300.0, 6000.0)
plot newMapLinToExpNoTemps(x, 10.0, 20.0, 200.0, 300.0, 6000.0)

print newMapExpToLinNoTemps(300.0, 10.0, 300.0, 6000.0, 20.0, 200.0)
print newMapExpToLinNoTemps(6000.0, 10.0, 300.0, 6000.0, 20.0, 200.0)
plot newMapExpToLinNoTemps(x, 10.0, 300.0, 6000.0, 20.0, 200.0)

# inverse test
plot newMapExpToLinNoTemps(newMapLinToExpNoTemps(x, 10.0, 20.0, 200.0, 300.0, 6000.0), 10.0, 300.0, 6000.0, 20.0, 200.0)
*/

/*
Old linear/exponential mappings without free choice of i_base

float mapLinToExp(float i_value,
                  float i_fromStart, float i_fromEnd,
                  float i_toStart, float i_toEnd)
{
    float rv = pow(i_toEnd / i_toStart,
                   // value in from range, 0..1
                   (i_value - i_fromStart) / (i_fromEnd - i_fromStart))
        * i_toStart;

    return rv;
}

float mapExpToLin(float i_value,
                  float i_fromStart, float i_fromEnd,
                  float i_toStart, float i_toEnd)
{
    float rv = logN(i_fromEnd / i_fromStart, i_value / i_fromStart)
        * (i_toEnd - i_toStart)
        + i_toStart;

    // Suppress NaN
    if (rv != rv)
        rv = i_fromStart;

    // Suppress infinities
    if (rv == Float.NEGATIVE_INFINITY || rv == Float.POSITIVE_INFINITY)
        rv = 0.0;

    return rv;
}
*/

// + }}}

// + Custom for SensiphoneAndWarble {{{

float linearStretch(float i_value,
                    float i_toStart, float i_toEnd)
// Translate a sensor value from its normalized range [0.0 .. 1.0],
// into a new range chosen by start and end values,
// in a linear (straight) way.
//
// Params:
//  i_value:
//   The sensor value to scale.
//   In range [0.0 .. 1.0].
//  i_toStart:
//   The start of the new range to translate to.
//  i_toEnd:
//   The end of the new range to translate to.
//
// Returns:
//  A number in the new range ([i_toStart .. i_toEnd]).
{
    // Stretch
    return mapLinToLin(
        // value
        i_value,
        // from [0 .. 1]
        0.0, 1.0,
        // to specified [start .. end]
        i_toStart, i_toEnd);
}

float linearSpread(float i_value,
                   float i_toMiddle, float i_toSpread)
// Translate a sensor value from its normalized range [0.0 .. 1.0],
// into a new range chosen by a central value and an amount of spread to either side,
// in a linear (straight) way.
//
// Params:
//  i_value:
//   The sensor value to scale.
//   In range [0.0 .. 1.0].
//  i_toMiddle:
//   The middle value of the new range to translate to.
//  i_toSpread:
//   The size above and below the middle value of the new range to translate to.
//
// Returns:
//  A number in the new range ([i_toMiddle - i_toSpread .. i_toMiddle + i_toSpread]).
{
    return linearStretch(i_value,
                         i_toMiddle - i_toSpread, i_toMiddle + i_toSpread);
}


float exponentialStretch(float i_value,
                         float i_base,
                         float i_toStart, float i_toEnd)
// Translate a sensor value from its normalized range [0.0 .. 1.0],
// into a new range chosen by start and end values,
// in an exponential (curved) way.
//
// Params:
//  i_value:
//   The sensor value to scale.
//   In range [0.0 .. 1.0].
//  i_base:
//   The amount of curvature in the transfer function.
//   > 1:
//    A shallow, then steep translation curve.
//    As i_value rises from 0.0 to 1.0 the result will rise slowly away from i_toStart at first,
//    then shoot up towards i_toEnd.
//    Higher base values make this effect more pronounced.
//   1:
//    A linear (straight) translation curve, ie. no curvature.
//    This is the same as just using linearStretch().
//   < 1:
//    A steep, then shallow translation curve.
//    As i_value rises from 0.0 to 1.0 the result will shoot up quickly away from i_toStart at first,
//    then slowly close in on i_toEnd.
//    Lower base values make this effect more pronounced.
//   <= 0:
//    Bases less than or equal to 0 are invalid and should not be used.
//  i_toStart:
//   The start of the new range to translate to.
//  i_toEnd:
//   The end of the new range to translate to.
//
// Returns:
//  A number in the new range ([i_toStart .. i_toEnd]).
//
// Examples:
//  exponentialStretch(0.0, 16, 1, 16) = 1.0
//  exponentialStretch(0.25, 16, 1, 16) = 2.0
//  exponentialStretch(0.5, 16, 1, 16) = 4.0
//  exponentialStretch(0.75, 16, 1, 16) = 8.0
//  exponentialStretch(1.0, 16, 1, 16) = 16.0
{
    // Stretch
    return newMapLinToExp(
        // value
        i_value,
        // with base
        i_base,
        // from [0 .. 1]
        0.0, 1.0,
        // to specified [start .. end]
        i_toStart, i_toEnd);
}

float exponentialSpread(float i_value,
                        float i_base,
                        float i_toMiddle, float i_toSpread)
// Translate a sensor value from its normalized range [0.0 .. 1.0],
// into a new range chosen by a central value and an amount of spread to either side,
// in an exponential (curved) way.
//
// Params:
//  i_value:
//   The sensor value to scale.
//   In range [0.0 .. 1.0].
//  i_base:
//   The amount of curvature in the transfer function.
//   > 1:
//    A shallow, then steep translation curve.
//    As i_value rises from 0.0 to 1.0 the result will rise slowly away from i_toStart at first,
//    then shoot up towards i_toEnd.
//    Higher base values make this effect more pronounced.
//   1:
//    A linear (straight) translation curve, ie. no curvature.
//    This is the same as just using linearStretch().
//   < 1:
//    A steep, then shallow translation curve.
//    As i_value rises from 0.0 to 1.0 the result will shoot up quickly away from i_toStart at first,
//    then slowly close in on i_toEnd.
//    Lower base values make this effect more pronounced.
//   <= 0:
//    Bases less than or equal to 0 are invalid and should not be used.
//  i_toMiddle:
//   The middle value of the new range to translate to.
//  i_toSpread:
//   The size above and below the middle value of the new range to translate to.
//
// Returns:
//  A number in the new range ([i_toMiddle / i_base^i_toSpread .. i_toMiddle * i_base^i_toSpread]).
//
// Examples:
//  exponentialSpread(0.0, 16, 4, 0.5) = 1.0
//  exponentialSpread(0.25, 16, 4, 0.5) = 2.0
//  exponentialSpread(0.5, 16, 4, 0.5) = 4.0
//  exponentialSpread(0.75, 16, 4, 0.5) = 8.0
//  exponentialSpread(1.0, 16, 4, 0.5) = 16.0
{
    // i_value range is [0 .. 1]
    i_value -= 0.5;
    // i_value range is [-0.5 .. +0.5]
    i_value *= 2;
    // i_value range is [-1 .. +1]
    i_value *= i_toSpread;
    // i_value range is [-i_toSpread .. +i_toSpread]
    i_value = pow(i_base, i_value);
    // i_value range is [1 / i_base^i_toSpread .. 1 .. i_base^i_toSpread]
    i_value *= i_toMiddle;

    return i_value;
}


float logarithmicStretch(float i_value,
                         float i_base,
                         float i_toStart, float i_toEnd)
{
    // Stretch
    return newMapExpToLin(
        // value
        i_value,
        // with base
        i_base,
        // from [0 .. 1]
        0.0, 1.0,
        // to specified [start .. end]
        i_toStart, i_toEnd);
}

// + }}}
