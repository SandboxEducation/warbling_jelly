
import java.util.Arrays;

import ddf.minim.UGen;

public class Warble
    extends ddf.minim.UGen
    implements ddf.minim.ugens.Instrument
{
    // + Construction {{{

    /*
    public Warble(int i_sampleCount,
                  float i_base_frequency,
                  float i_amplitude_peak, float[] i_amplitude_envelopeBreakpoints,
                  float i_glissando_peakInHz, float[] i_glissando_envelopeBreakpoints,
                  float i_pulse_sampleCount, float[] i_pulse_envelopeBreakpoints,
                  float i_fm_index, float i_fm_frequency)
    {
        this(i_base_frequency,
             i_amplitude_peak, new OneShotEnvelope(OneShotEnvelope.scaleBreakpointsTo(i_amplitude_envelopeBreakpoints, (float)i_sampleCount)),
             i_glissando_peakInHz, new OneShotEnvelope(OneShotEnvelope.scaleBreakpointsTo(i_glissando_envelopeBreakpoints, (float)i_sampleCount)),
             new LoopedEnvelope(LoopedEnvelope.scaleBreakpointsTo(i_pulse_envelopeBreakpoints, (float)i_pulse_sampleCount), (int)i_pulse_sampleCount),
             i_fm_index, i_fm_frequency);
    }
    */

    public Warble(ddf.minim.AudioOutput i_speaker)
    {
        // Create oscillator objects
        //  Base
        base_oscil = new Oscillator(0, (float)1.0, ddf.minim.ugens.Waves.SINE);
        //  FM
        fm_oscil = new Oscillator((float)fm_frequency, (float)1.0, ddf.minim.ugens.Waves.SINE);

        // Create empty envelope objects (to avoid a NullPointerException in case uGenerate() gets called,
        // though user should replace these envelopes imminently)
        amplitude_envelope = new CompoundEnvelope(
            new OneShotEnvelope(new float[]{ 0.0f, 0.0f }),
            null,
            new OneShotEnvelope(new float[]{ 0.0f, 0.0f }));
        glissando_envelope = new OneShotEnvelope(new float[]{ 0.0f, 0.0f });
        pulse_envelope = new LoopedEnvelope(new float[]{ 0.0f, 0.0f }, 0.0f);

        // Save audio output for patching/unpatching later when start or end note
        m_speaker = i_speaker;

        // Patch temporarily to speaker just to update self with the current sample rate
        this.patch(m_speaker);
        this.unpatch(m_speaker);
    }

    public Warble(ddf.minim.AudioOutput i_speaker,
                  float i_base_frequency,
                  float i_amplitude_peak, CompoundEnvelope i_amplitude_envelope,
                  float i_glissando_peakInHz, IEnvelope i_glissando_envelope,
                  LoopedEnvelope i_pulse_envelope,
                  float i_fm_index, float i_fm_frequency)
    {
        // Base oscillator
        base_frequency = i_base_frequency;
        base_oscil = new Oscillator((float)base_frequency, (float)1.0, ddf.minim.ugens.Waves.SINE);
        base_oscil.setSampleRate(44100);

        // Amplitude
        amplitude_peak = i_amplitude_peak;
        amplitude_envelope = i_amplitude_envelope;

        // Glissando
        glissando_peakInHz = i_glissando_peakInHz;
        glissando_envelope = i_glissando_envelope;

        // Pulses
        pulse_envelope = i_pulse_envelope;

        // FM oscillator
        fm_frequency = i_fm_frequency;
        fm_oscil = new Oscillator((float)fm_frequency, (float)1.0, ddf.minim.ugens.Waves.SINE);
        fm_oscil.setSampleRate(44100);
        fm_index = i_fm_index;

        // Save audio output for patching/unpatching later when start or end note
        m_speaker = i_speaker;

        // Patch temporarily to speaker just to update self with the current sample rate
        this.patch(m_speaker);
        this.unpatch(m_speaker);
    }

    public Warble duplicate()
    // Make another Warble with the same properties as this one.
    // (This is not a 'clone' - a new object is reconstructed with the current property values,
    // hidden internal state is not copied.)
    {
        return new Warble(
            m_speaker,
            base_frequency,
            amplitude_peak, new CompoundEnvelope(
                new OneShotEnvelope(((OneShotEnvelope)(amplitude_envelope.getNoteOnEnvelope())).getBreakpoints().clone()),
                null,
                new OneShotEnvelope(((OneShotEnvelope)(amplitude_envelope.getNoteOffEnvelope())).getBreakpoints().clone())),
            glissando_peakInHz, new OneShotEnvelope(((OneShotEnvelope)(glissando_envelope)).getBreakpoints().clone()),
            new LoopedEnvelope(pulse_envelope.getBreakpoints().clone(), pulse_envelope.getLoopAtSampleNo()),
            fm_index, fm_frequency);
    }

    // + }}}

    // + Audio output {{{

    private ddf.minim.AudioOutput m_speaker;

    // + }}}

    // + Sample rate {{{

    @Override // method in ddf.minim.UGen
    protected void sampleRateChanged()
    // This will called when the UGen is patched somewhere or if the sample rate subsequently changes.
    {
        base_oscil.setSampleRate(sampleRate());
        fm_oscil.setSampleRate(sampleRate());
    }

    // + }}}

    // + Sound properties and objects {{{

    // + + Base oscillator {{{

    Oscillator base_oscil;
    float base_frequency;

    // + + }}}

    // + + Amplitude {{{

    public float amplitude_peak;
    CompoundEnvelope amplitude_envelope;

    // + }}}

    // + + Glissando {{{

    float glissando_peakInHz;
    IEnvelope glissando_envelope;

    // + + }}}

    // + + Pulses {{{

    LoopedEnvelope pulse_envelope;

    void pulse_envelope_scaleDurationTo(float i_durationInSeconds)
    {
        pulse_envelope.scaleBreakpointDurationTo(i_durationInSeconds * sampleRate());
    }

    // + + }}}

    // + + FM {{{

    Oscillator fm_oscil;
    float fm_frequency;
    float fm_index;

    // + + }}}

    // + }}}

    // + Usage as a Minim Instrument {{{

    @Override // method in ddf.minim.ugens.Instrument
    public void noteOn(float i_duration)
    {
        noteOn();
    }

    /*
    @Override // method in ddf.minim.ugens.Instrument
    public void noteOff()
    // Implemented below
    */

    // + }}}

    // + Sound lifecycle {{{

    private boolean m_noteInProgress = false;
    public boolean noteInProgress()
    {
        return m_noteInProgress;
    }

    public void noteOn()
    {
        //System.out.println("Warble noteOn()");

        amplitude_envelope.noteOn();
        glissando_envelope.restart();

        // We only ever want to patch a particular Warble instance once.
        // Unpatch ourself before repatching to ensure this is true
        // (if already unpatched, unpatch() will do nothing).
        this.unpatch(m_speaker);
        this.patch(m_speaker);

        m_noteInProgress = true;
    }

    public void noteOff()
    {
        //System.out.println("Warble noteOff()");

        amplitude_envelope.noteOff();

        m_noteInProgress = false;
    }

    public void noteToggle()
    {
        //System.out.println(m_noteInProgress);
        if (m_noteInProgress)
            noteOff();
        else
            noteOn();
    }

    // + }}}

    // + Generate samples {{{

    @Override // method in ddf.minim.UGen
    protected void uGenerate(float[] o_channels)
    {
        if (amplitude_envelope.ended())
        {
            this.unpatch(m_speaker);
        }

        fm_oscil.setFrequency(fm_frequency);

        base_oscil.setFrequency(base_frequency +
                                glissando_envelope.play() * glissando_peakInHz +  //Warble.java:144:0:144:0: NullPointerException
                                fm_oscil.run() * fm_frequency * fm_index);

        double sample = base_oscil.run();
        sample *= amplitude_envelope.play() * amplitude_peak;
        sample *= pulse_envelope.play();

        // Write sample to all channels
        Arrays.fill(o_channels, (float)sample);
    }

    // + }}}
}
