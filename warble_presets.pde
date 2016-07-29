
void warblePreset_cricket_setup()
{
    //// Create and set Warble's envelopes

    // Shape of amplitude
    warble.amplitude_envelope = new CompoundEnvelope(
        OneShotEnvelope.withPrescale(new float[]{ 0.0, 0.0,  0.0625, 1.0 }, speaker.sampleRate()),
        null,
        OneShotEnvelope.withPrescale(new float[]{ 0.0, 1.0,  0.0625, 0.0 }, speaker.sampleRate()));

    // Shape of glissando
    warble.glissando_envelope = OneShotEnvelope.withPrescale(new float[]{ 0.0, 0.0,  0.28125, 0.2,  0.45, 1.0 }, speaker.sampleRate());

    // Length and shape of pulses
    float pulseDurationInSeconds = 0.05;
    warble.pulse_envelope = LoopedEnvelope.withPrescale(new float[]{ 0.0, 0.0,  0.05, 0.0,  0.25, 1.0,  0.4, 0.0,  1.0, 0.0 }, pulseDurationInSeconds * speaker.sampleRate());


    //// Set some basic initial sound parameters

    warble.amplitude_peak = 0.5;

    warble.base_frequency = 2000;

    warble.glissando_peakInHz = 500;

    warble.fm_index = 0.01;
    warble.fm_frequency = 40;
}

void warblePreset_cricket_control()
{
    //// Read sensors and set Warble sound parameters accordingly

    // Sensor 0 to amplitude
    if (sensorIsPresent(0))
    {
        if (sensorTouched(0))
        {
            warble.noteToggle();
        }

        warble.amplitude_peak = 0.75;
        //warble.amplitude_peak = sensorValue(0);
    }

    // Sensor 1 to base frequency
    if (sensorIsPresent(1))
    {
        warble.base_frequency = exponentialSpread(sensorValue(1), 2, 2000, 1);
    }

    // Fixed amount for glissando
    warble.glissando_peakInHz = 500;

    // Sensor 2 to pulse duration
    if (sensorIsPresent(2))
    {
        warble.pulse_envelope_scaleDurationTo(
            exponentialSpread(sensorValue(2), 7, 0.05, -1.2));
        //exponentialSpread(sensorValue(2), 7, 10.0, 0.05));
    }

    // Sensor 3 to FM index
    if (sensorIsPresent(3))
    {
        warble.fm_index = linearStretch(sensorValue(3), 0.01, 1.0);
    }

    // Sensor 4 to FM frequency
    if (sensorIsPresent(4))
    {
        warble.fm_frequency = linearStretch(sensorValue(4), 40, 400);
    }
}


void warblePreset_frog_setup()
{
    //// Create and set Warble's envelopes

    // Shape of amplitude
    warble.amplitude_envelope = new CompoundEnvelope(
        OneShotEnvelope.withPrescale(new float[]{ 0.0, 0.0,  0.0625, 1.0 }, speaker.sampleRate()),
        null,
        OneShotEnvelope.withPrescale(new float[]{ 0.0, 1.0,  0.8625, 0.0 }, speaker.sampleRate()));

    // Shape of glissando
    warble.glissando_envelope = OneShotEnvelope.withPrescale(new float[]{ 0.0, 0.0,  0.125, 0.2,  0.2, 1.0  }, speaker.sampleRate());

    // Length and shape of pulses
    float pulseDurationInSeconds = 0.0357;
    warble.pulse_envelope = LoopedEnvelope.withPrescale(new float[]{ 0.0, 0.1,  0.217, 0.4,  0.26, 0.75,  0.434, 0.9,  0.652, 1.0,  0.86, 0.9,  1.0, 0.1 }, pulseDurationInSeconds * speaker.sampleRate());


    //// Set some basic initial sound parameters

    warble.amplitude_peak = 0.5;

    warble.base_frequency = 480;

    warble.glissando_peakInHz = 50;

    warble.fm_index = 1.75;
    warble.fm_frequency = 40;
}

void warblePreset_frog_control()
{
    //// Read sensors and set Warble sound parameters accordingly

    // Sensor 0 to amplitude
    if (sensorIsPresent(0))
    {
        if (sensorTouched(0))
        {
            warble.noteToggle();
        }

        warble.amplitude_peak = 0.75;
        //warble.amplitude_peak = sensorValue(0);
    }

    // Sensor 1 to base frequency
    if (sensorIsPresent(1))
    {
        warble.base_frequency = exponentialSpread(sensorValue(1), 2, 480, 1);
    }

    // Fixed amount for glissando
    warble.glissando_peakInHz = 50;

    // Sensor 2 to pulse duration
    if (sensorIsPresent(2))
    {
        warble.pulse_envelope_scaleDurationTo(
            exponentialSpread(sensorValue(2), 7, 0.0357, -0.2));
    }

    // Sensor 3 to FM index
    if (sensorIsPresent(3))
    {
        warble.fm_index = linearStretch(sensorValue(3), 1.75, 5.75);
    }

    // Sensor 4 to FM frequency
    if (sensorIsPresent(4))
    {
        warble.fm_frequency = exponentialStretch(sensorValue(4), 2, 40, 50);
    }
}


void warblePreset_prettyTweetingBird_setup()
{
    //// Create and set Warble's envelopes

    // Shape of amplitude
    warble.amplitude_envelope = new CompoundEnvelope(
        OneShotEnvelope.withPrescale(new float[]{ 0.0, 0.0,  0.1875, 1.0 }, speaker.sampleRate()),
        null,
        OneShotEnvelope.withPrescale(new float[]{ 0.0, 1.0,  0.1875, 0.0 }, speaker.sampleRate()));

    // Shape of glissando
    warble.glissando_envelope = OneShotEnvelope.withPrescale(new float[]{ 0.0, 0.0,  0.375, 0.2,  0.6, 1.0 }, speaker.sampleRate());

    // Length and shape of pulses
    float pulseDurationInSeconds = 0.144;
    warble.pulse_envelope = LoopedEnvelope.withPrescale(new float[]{ 0.0, 0.0,  0.05, 0.0,  0.25, 1.0,  0.4, 0.0,  1.0, 0.0 }, pulseDurationInSeconds * speaker.sampleRate());


    //// Set some basic initial sound parameters

    warble.amplitude_peak = 0.5;

    warble.base_frequency = 6000;

    warble.glissando_peakInHz = 2393;

    warble.fm_index = 30.01;
    warble.fm_frequency = 34;
}

void warblePreset_prettyTweetingBird_control()
{
    //// Read sensors and set Warble sound parameters accordingly

    // Sensor 0 to amplitude
    if (sensorIsPresent(0))
    {
        if (sensorTouched(0))
        {
            warble.noteToggle();
        }

        warble.amplitude_peak = 0.75;
        //warble.amplitude_peak = sensorValue(0);
    }

    // Sensors 1 & 3 to base frequency
    //  (sensor 1 going upwards, sensor 3 going downwards)
    if (sensorIsPresent(1))
    {
        warble.base_frequency = exponentialStretch(sensorValue(1) - sensorValue(3)*2, 2, 6000, 12000);
    }

    // Fixed amount for glissando
    warble.glissando_peakInHz = 2393;

    // Sensor 2 to pulse duration
    if (sensorIsPresent(2))
    {
        warble.pulse_envelope_scaleDurationTo(
            exponentialSpread(sensorValue(2), 7, 0.144, -1.5));
    }

    // Sensor 5 to FM index
    if (sensorIsPresent(5))
    {
        warble.fm_index = linearStretch(sensorValue(5), 30.01, 50.01);
    }

    // Sensor 4 to FM frequency
    if (sensorIsPresent(4))
    {
        warble.fm_frequency = linearStretch(sensorValue(4), 24, 154);
    }
}


void warblePreset_helicopterComingThrough_setup()
{
    //// Create and set Warble's envelopes

    // Shape of amplitude
    warble.amplitude_envelope = new CompoundEnvelope(
        OneShotEnvelope.withPrescale(new float[]{ 0.0, 0.0,  0.3453533115671642, 1.0 }, speaker.sampleRate()),
        null,
        OneShotEnvelope.withPrescale(new float[]{ 0.0, 1.0,  0.3453533115671642, 0.0 }, speaker.sampleRate()));

    // Shape of glissando
    warble.glissando_envelope = OneShotEnvelope.withPrescale(new float[]{ 0.0, 0.0,  0.6907066231343284, 0.2,  1.1051305970149254, 1.0 }, speaker.sampleRate());

    // Length and shape of pulses
    float pulseDurationInSeconds = 0.05882434840721765;
    warble.pulse_envelope = LoopedEnvelope.withPrescale(new float[]{ 0.0, 0.0,  0.05, 0.0,  0.25, 1.0,  0.4, 0.0,  1.0, 0.0 }, pulseDurationInSeconds * speaker.sampleRate());


    //// Set some basic initial sound parameters

    warble.amplitude_peak = 0.5;

    warble.base_frequency = 3375;

    warble.glissando_peakInHz = -1095.2606371129427;

    warble.fm_index = 6.61672978391624;
    warble.fm_frequency = 686.1773223435063;
}

void warblePreset_helicopterComingThrough_control()
{
    //// Read sensors and set Warble sound parameters accordingly

    // Sensor 0 to amplitude
    if (sensorIsPresent(0))
    {
        if (sensorTouched(0))
        {
            warble.noteToggle();
        }

        warble.amplitude_peak = 0.75;
        //warble.amplitude_peak = sensorValue(0);
    }

    // Sensor 1 to base frequency
    if (sensorIsPresent(1))
    {
        warble.base_frequency = exponentialSpread(sensorValue(1), 2, 3375, 0.2);
    }

    // Fixed amount for glissando
    warble.glissando_peakInHz = -1095.2606371129427;

    // Sensor 2 to pulse duration
    if (sensorIsPresent(2))
    {
        warble.pulse_envelope_scaleDurationTo(
            exponentialSpread(sensorValue(2), 7, 0.05882434840721765, -0.5));
    }

    // Sensor 3 to FM index
    if (sensorIsPresent(3))
    {
        warble.fm_index = linearStretch(sensorValue(3), 6.61672978391624, 9.0);
    }

    // Sensor 4 to FM frequency
    if (sensorIsPresent(4))
    {
        warble.fm_frequency = linearStretch(sensorValue(4), 656.1773223435063, 1000);
    }
}


void warblePreset_choppedBird_setup()
{
    //// Create and set Warble's envelopes

    // Shape of amplitude
    warble.amplitude_envelope = new CompoundEnvelope(
        OneShotEnvelope.withPrescale(new float[]{ 0.0, 0.0,  0.5, 1.0 }, speaker.sampleRate()),
        null,
        OneShotEnvelope.withPrescale(new float[]{ 0.0, 1.0,  0.5, 0.0 }, speaker.sampleRate()));

    // Shape of glissando
    warble.glissando_envelope = OneShotEnvelope.withPrescale(new float[]{ 0.0, 0.0,  1.0, 0.2,  1.6, 1.0 }, speaker.sampleRate());

    // Length and shape of pulses
    float pulseDurationInSeconds = 0.0011277567386945868;
    warble.pulse_envelope = LoopedEnvelope.withPrescale(new float[]{ 0.0, 0.0,  0.05, 0.0,  0.25, 1.0,  0.4, 0.0,  1.0, 0.0 }, pulseDurationInSeconds * speaker.sampleRate());


    //// Set some basic initial sound parameters

    warble.amplitude_peak = 0.5;

    warble.base_frequency = 1660.8097571842281;

    warble.glissando_peakInHz = 144.0187124081085;

    warble.fm_index = 9.630346402316775;
    warble.fm_frequency = 1.6846736466919137;
}

void warblePreset_choppedBird_control()
{
    //// Read sensors and set Warble sound parameters accordingly

    // Sensor 0 to amplitude
    if (sensorIsPresent(0))
    {
        if (sensorTouched(0))
        {
            warble.noteToggle();
        }

        warble.amplitude_peak = 0.75;
        //warble.amplitude_peak = sensorValue(0);
    }

    // Sensor 1 to base frequency
    if (sensorIsPresent(1))
    {
        warble.base_frequency = exponentialSpread(sensorValue(1), 2, 1660.8097571842281, 7.0/12.0);
    }

    // Fixed amount for glissando
    warble.glissando_peakInHz = 144.0187124081085;

    // Sensor 2 to pulse duration
    if (sensorIsPresent(2))
    {
        warble.pulse_envelope_scaleDurationTo(
            //exponentialSpread(sensorValue(2), 7, 0.0011277567386945868, -0.05));
            linearSpread(sensorValue(2), 0.0011277567386945868, -0.00005));
    }

    // Sensor 3 to FM frequency
    if (sensorIsPresent(3))
    {
        warble.fm_frequency = linearStretch(sensorValue(3), 1.2846736466919137, 10.2);
    }

    // Sensor 4 to FM index
    if (sensorIsPresent(4))
    {
        warble.fm_index = linearSpread(sensorValue(4), 9.630346402316775, 0.2);
    }
}


void warblePreset_bouncingRemains_setup()
{
    //// Create and set Warble's envelopes

    // Shape of amplitude
    warble.amplitude_envelope = new CompoundEnvelope(
        OneShotEnvelope.withPrescale(new float[]{ 0.0, 0.0,  0.75, 1.0 }, speaker.sampleRate()),
        null,
        OneShotEnvelope.withPrescale(new float[]{ 0.0, 1.0,  1.75, 0.0 }, speaker.sampleRate()));

    // Shape of glissando
    warble.glissando_envelope = OneShotEnvelope.withPrescale(new float[]{ 0.0, 0.0,  1.5, 0.2,  2.4, 1.0 }, speaker.sampleRate());

    // Length and shape of pulses
    float pulseDurationInSeconds = 0.19716250835375362;
    warble.pulse_envelope = LoopedEnvelope.withPrescale(new float[]{ 0.0, 0.0,  0.05, 0.0,  0.25, 1.0,  0.4, 0.0,  1.0, 0.0 }, pulseDurationInSeconds * speaker.sampleRate());


    //// Set some basic initial sound parameters

    warble.amplitude_peak = 0.5;

    warble.base_frequency = 3375;

    warble.glissando_peakInHz = 2389.50768545333;

    warble.fm_index = 1000;
    warble.fm_frequency = 1.392292269993317;
}

void warblePreset_bouncingRemains_control()
{
    //// Read sensors and set Warble sound parameters accordingly

    // Sensor 0 to amplitude
    if (sensorIsPresent(0))
    {
        if (sensorTouched(0))
        {
            warble.noteToggle();
        }

        warble.amplitude_peak = 0.75;
        //warble.amplitude_peak = sensorValue(0);
    }

    // Sensor 1 to base frequency
    if (sensorIsPresent(1))
    {
        warble.base_frequency = exponentialSpread(sensorValue(1), 2, 3375, 2.5);
    }

    // Fixed amount for glissando
    warble.glissando_peakInHz = 2389.50768545333;

    // Sensor 2 to pulse duration
    if (sensorIsPresent(2))
    {
        warble.pulse_envelope_scaleDurationTo(
            exponentialSpread(sensorValue(2), 7, 0.19716250835375362, -0.7));
    }

    // Sensor 3 to FM frequency
    if (sensorIsPresent(3))
    {
        warble.fm_frequency = linearStretch(sensorValue(3), 1.392292269993317, 14);
    }

    // Sensor 4 to FM index
    if (sensorIsPresent(4))
    {
        warble.fm_index = linearStretch(sensorValue(4), 500, 3000);
    }
}


void warblePreset_almostMusical_setup()
{
    //// Create and set Warble's envelopes

    // Shape of amplitude
    warble.amplitude_envelope = new CompoundEnvelope(
        OneShotEnvelope.withPrescale(new float[]{ 0.0, 0.0,  0.75, 1.0 }, speaker.sampleRate()),
        null,
        OneShotEnvelope.withPrescale(new float[]{ 0.0, 1.0,  0.75, 0.0 }, speaker.sampleRate()));

    // Shape of glissando
    warble.glissando_envelope = OneShotEnvelope.withPrescale(new float[]{ 0.0, 0.0,  1.5, 0.2,  2.4, 1.0 }, speaker.sampleRate());

    // Length and shape of pulses
    float pulseDurationInSeconds = 0.14202773446201825;
    warble.pulse_envelope = LoopedEnvelope.withPrescale(new float[]{ 0.0, 0.0,  0.05, 0.0,  0.25, 1.0,  0.8233333230018616, 0.5550000071525574,  1.0, 0.0 }, pulseDurationInSeconds * speaker.sampleRate());


    //// Set some basic initial sound parameters

    warble.amplitude_peak = 0.5;

    warble.base_frequency = 649.2537313432836;

    warble.glissando_peakInHz = 1900.7761194029854;

    warble.fm_index = 5.1492537313432845;
    warble.fm_frequency = 451.4925373134329;
}

void warblePreset_almostMusical_control()
{
    //// Read sensors and set Warble sound parameters accordingly

    // Sensor 0 to amplitude
    if (sensorIsPresent(0))
    {
        if (sensorTouched(0))
        {
            warble.noteToggle();
        }

        warble.amplitude_peak = 0.75;
        //warble.amplitude_peak = sensorValue(0);
    }

    // Sensor 1 to base frequency
    if (sensorIsPresent(1))
    {
        warble.base_frequency = exponentialSpread(sensorValue(1), 2, 649.2537313432836, 1);
    }

    // Fixed amount for glissando
    warble.glissando_peakInHz = 1900.7761194029854;

    // Sensor 2 to pulse duration
    if (sensorIsPresent(2))
    {
        warble.pulse_envelope_scaleDurationTo(
            exponentialSpread(sensorValue(2), 7, 0.14202773446201825, 2.0));
    }

    // Sensor 3 to FM index
    if (sensorIsPresent(3))
    {
        warble.fm_index = linearStretch(sensorValue(3), 5.1492537313432845, 10.0);
    }

    // Sensor 4 to FM frequency
    if (sensorIsPresent(4))
    {
        warble.fm_frequency = linearStretch(sensorValue(4), 351.4925373134329, 1470);
    }
}
