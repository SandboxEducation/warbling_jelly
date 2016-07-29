//package ddf.minim.ugens;


// Java std
import java.util.Arrays;

// Base class
import ddf.minim.UGen;


class Oscillator
    extends UGen
// A UGen that generates audio by oscillating over a Waveform at a particular frequency.
//
// eg.
//  Oscillator testTone = new Oscillator(440, 1, ddf.minim.ugens.Waves.SINE);
//  Then patch to an AudioOutput to generate a continuous sine wave tone at 440 Hz.
//
// Oscillates over a generic Waveform object.
// Generally, you will use predefined Waveforms from the Waves class,
// or generated Waveforms using the WavetableGenerator class.
//
// Also accepts the Frequency class where appropriate allowing you to specify frequencies
// in terms of pitch, midi note, or hertz.
// eg.
//  Oscillator testTone = new Oscillator( Frequency.ofPitch("A4"), 1, ddf.minim.ugens.Waves.SINE );
{
    // the waveform we will oscillate over
    private ddf.minim.ugens.Waveform m_waveform;

    private float m_currentPhase;
    // Current position in wave in range [0..1]

    // + Construction {{{

    public Oscillator(ddf.minim.ugens.Frequency i_frequency, float i_amplitude, ddf.minim.ugens.Waveform i_waveform, float i_phaseOffset, float i_dcOffset)
    // Construct while specifying waveform,
    // frequency as a Frequency object,
    // phase offset and DC offset.
    //
    // Params:
    //  i_frequency:
    //   Frequency
    //  i_amplitude:
    //   Gain to apply to returned values
    //  i_waveform:
    //   Waveform to oscillate over / read from
    //  i_phaseOffset:
    //   Phase offset to set.
    //  i_dcOffset:
    //   DC offset to set.
    {
        super();

        // Save properties
        m_frequency = i_frequency.asHz();
        m_amplitude = i_amplitude;
        m_waveform = i_waveform;
        m_phaseOffset = i_phaseOffset;
        m_dcOffset = i_dcOffset;

        // Reset state
        m_currentPhase = 0.0f;
        m_oneOverSampleRate = 1.0f;
    }

    public Oscillator(float i_frequencyInHz, float i_amplitude, ddf.minim.ugens.Waveform i_waveform, float i_phaseOffset, float i_dcOffset)
    // Construct while specifying waveform,
    // frequency as a float,
    // phase offset and DC offset.
    //
    // Params:
    //  i_frequencyInHz:
    //   Frequency in Hz
    //  i_amplitude:
    //   Gain to apply to returned values
    //  i_waveform:
    //   Waveform to oscillate over / read from
    //  i_phaseOffset:
    //   Phase offset to set.
    //  i_dcOffset:
    //   DC offset to set.
    {
        this(ddf.minim.ugens.Frequency.ofHertz(i_frequencyInHz), i_amplitude, i_waveform, i_phaseOffset, i_dcOffset);
    }

    public Oscillator(ddf.minim.ugens.Frequency i_frequency, float i_amplitude, ddf.minim.ugens.Waveform i_waveform)
    // Construct while specifying waveform
    // and frequency as a Frequency object
    //
    // Params:
    //  i_frequency:
    //   Frequency
    //  i_amplitude:
    //   Gain to apply to returned values
    //  i_waveform:
    //   Waveform to oscillate over / read from
    {
        this(i_frequency, i_amplitude, i_waveform,
             0.0f, 0.0f);
    }

    public Oscillator(float i_frequencyInHz, float i_amplitude, ddf.minim.ugens.Waveform i_waveform)
    // Construct while specifying waveform
    // and frequency as a float
    //
    // Params:
    //  i_frequencyInHz:
    //   Frequency in Hz
    //  i_amplitude:
    //   Gain to apply to returned values
    //  i_waveform:
    //   Waveform to oscillate over / read from
    {
        this(ddf.minim.ugens.Frequency.ofHertz(i_frequencyInHz), i_amplitude, i_waveform);
    }

    public Oscillator(ddf.minim.ugens.Frequency i_frequency, float i_amplitude)
    // Construct with a sine wave waveform
    // and frequency as a Frequency object
    //
    // Params:
    //  i_frequency:
    //   Frequency
    //  i_amplitude:
    //   Gain to apply to returned values
    {
        this(i_frequency, i_amplitude, ddf.minim.ugens.Waves.SINE);
    }

    public Oscillator(float i_frequencyInHz, float i_amplitude)
    // Construct with a sine wave waveform
    // and frequency as a float
    //
    // Params:
    //  i_frequencyInHz:
    //   Frequency in Hz
    //  i_amplitude:
    //   Gain to apply to returned values
    {
        this(ddf.minim.ugens.Frequency.ofHertz(i_frequencyInHz), i_amplitude);
    }

    public Oscillator(Oscillator i_other)
    // Construct with the same properties as another oscillator.
    //
    // Params:
    //  i_other:
    //   The Oscillator to copy the properties from.
    //   Note that the waveform is only copied by reference.
    //
    // Returns:
    //  this.
    {
        this(i_other.m_frequency, i_other.m_amplitude, i_other.m_waveform, i_other.m_phaseOffset, i_other.m_dcOffset);
    }

    // + }}}

    // + Sample rate {{{

    private float m_oneOverSampleRate;
    // For dividing by sample rate

    @Override // in UGen
    protected void sampleRateChanged()
    // This will be called any time the sample rate changes.
    {
        // Update dependent values
        m_oneOverSampleRate = 1 / sampleRate();

        // Update step increment
        m_phaseIncrement = m_frequency * m_oneOverSampleRate;
    }

    // + }}}

    // + Properties {{{

    // + + Frequency {{{

    private float m_frequency;
    // In Hz

    private float m_phaseIncrement;
    // Per-sample phase increment

    public void setFrequency(float i_frequencyInHz)
    // Set the frequency of this Oscillator.
    //
    // Params:
    //  i_frequencyInHz:
    //   Frequency in Hz
    {
        if (i_frequencyInHz == m_frequency)
            return;

        m_frequency = i_frequencyInHz;
        m_phaseIncrement = i_frequencyInHz * m_oneOverSampleRate;
    }

    public void setFrequency(ddf.minim.ugens.Frequency i_frequency)
    // Set the frequency of this Oscillator.
    //
    // Params:
    //  i_frequency:
    //   Frequency to set.
    {
        setFrequency(i_frequency.asHz());
    }

    // + + }}}

    // + + Amplitude {{{

    private float m_amplitude;

    public void setAmplitude(float i_amplitude)
    // Set the amplitude of this Oscillator.
    //
    // You might want to do this to change the amplitude of this Oscillator in response to eg. a button press,
    // but for controlling amplitude continuously over time you will usually want to use the frequency input.
    //
    // Params:
    //  i_amplitude:
    //   Amplitude to set.
    {
        m_amplitude = i_amplitude;
    }

    // + + }}}

    // + + Phase offset {{{

    private float m_phaseOffset;

    public void setPhaseOffset(float i_phaseOffset)
    // Set the phase offset of this Oscillator.
    //
    // Params:
    //  i_phaseOffset:
    //   Phase offset to set.
    {
        m_phaseOffset = i_phaseOffset;
    }

    // + + }}}

    // + + DC offset {{{

    public float m_dcOffset;

    public void setDcOffset(float i_dcOffset)
    // Set the dc offset of this Oscillator.
    //
    // Params:
    //  i_dcOffset:
    //   Dc offset to set.
    {
        m_dcOffset = i_dcOffset;
    }

    // + + }}}

    // + }}}

    // + Waveform {{{

    public void setWaveform(ddf.minim.ugens.Waveform i_waveform)
    // Change the Waveform used by this Oscillator.
    //
    // Params:
    //  i_waveform:
    //   The new Waveform to use
    {
        m_waveform = i_waveform;
    }

    public ddf.minim.ugens.Waveform getWaveform()
    // Get the Waveform used by this Oscillator.
    //
    // Returns:
    //   The current Waveform
    {
        return m_waveform;
    }

    // + }}}

    public void reset()
    // Reset the current phase of the Oscillator to the phase offset.
    //
    // You will typically use this when starting a new note with an
    // Oscillator that you have already used so that the waveform will begin sounding
    // at the beginning of its period, which will typically be a zero-crossing.
    // In other words, use this to prevent clicks when starting Oscils that have
    // been used before.
    {
        m_currentPhase = m_phaseOffset;
    }

    // + Run {{{

    public float run()
    {
        // Get current phase with phase offset included
        // and wrap to [0..1]
        float phaseWithOffset = m_currentPhase + m_phaseOffset;
        if (phaseWithOffset < 0.f)
            phaseWithOffset -= (int)phaseWithOffset - 1f;
        if (phaseWithOffset > 1.0f)
            phaseWithOffset -= (int)phaseWithOffset;

        // Advance current phase by increment
        // and wrap to [0..1]
        m_currentPhase += m_phaseIncrement;
        if (m_currentPhase < 0.f)
            m_currentPhase -= (int)m_currentPhase - 1f;
        if (m_currentPhase > 1.0f)
            m_currentPhase -= (int)m_currentPhase;

        // Read sample value from waveform, apply gain and DC offset, and return result
        return m_waveform.value(phaseWithOffset) * m_amplitude + m_dcOffset;
    }

    @Override
    protected void uGenerate(float[] o_channels)
    {
        float sample = run();
        Arrays.fill(o_channels, sample);
    }

    // + }}}
}
