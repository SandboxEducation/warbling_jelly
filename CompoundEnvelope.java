public class CompoundEnvelope implements IEnvelope
{
    // + Construction {{{

    public CompoundEnvelope(IEnvelope i_noteOnEnvelope, IEnvelope i_sustainEnvelope, IEnvelope i_noteOffEnvelope)
    {
        m_noteOnEnvelope = i_noteOnEnvelope;
        m_sustainEnvelope = i_sustainEnvelope;
        m_noteOffEnvelope = i_noteOffEnvelope;

        m_currentEnvelope = -1;
    }

    /*
    public CompoundEnvelope(float[] i_noteOnEnvelopeBreakpoints, float[] i_sustainEnvelopeBreakpoints, float[] i_noteOffEnvelopeBreakpoints)
    {
        m_noteOnEnvelope = i_noteOnEnvelope;
        m_sustainEnvelope = i_sustainEnvelope;
        m_noteOffEnvelope = i_noteOffEnvelope;

        m_currentEnvelope = -1;
    }
    */

    /*
    public CompoundEnvelope(IEnvelope i_noteOnEnvelope, IEnvelope i_noteOffEnvelope)
    {
        m_noteOnEnvelope = i_noteOnEnvelope;
        m_sustainEnvelope = null;
        m_noteOffEnvelope = i_noteOffEnvelope;

        m_currentEnvelope = -1;
    }

    public CompoundEnvelope(IEnvelope i_noteOnEnvelope)
    {
        m_noteOnEnvelope = i_noteOnEnvelope;
        m_sustainEnvelope = null;
        m_noteOffEnvelope = null;

        m_currentEnvelope = -1;
    }
    */

    // + }}}

    // + Envelopes {{{

    private IEnvelope m_noteOnEnvelope;
    public IEnvelope getNoteOnEnvelope()
    {
        return m_noteOnEnvelope;
    }

    private IEnvelope m_sustainEnvelope;
    public IEnvelope getSustainEnvelope()
    {
        return m_sustainEnvelope;
    }

    private IEnvelope m_noteOffEnvelope;
    public IEnvelope getNoteOffEnvelope()
    {
        return m_noteOffEnvelope;
    }


    public CompoundEnvelope scaleTimesBy(float i_scalingFactor)
    // Scale all time values (ie. breakpoints)
    // in all envelopes
    // by some factor.
    //
    // Params:
    //  i_scalingFactor:
    //   The factor to multiply each time value by.
    //
    // Returns:
    //  this.
    {
        if (m_noteOnEnvelope != null)
            m_noteOnEnvelope.scaleTimesBy(i_scalingFactor);
        if (m_sustainEnvelope != null)
            m_sustainEnvelope.scaleTimesBy(i_scalingFactor);
        if (m_noteOffEnvelope != null)
            m_noteOffEnvelope.scaleTimesBy(i_scalingFactor);

        //
        return this;
    }

    // + }}}

    // + Current envelope {{{

    private int m_currentEnvelope;
    // -1: not started yet
    // 0: noteOn
    // 1: sustain
    // 2: noteOff
    // 3: ended

    public void restart()
    {
        m_currentEnvelope = -1;  // [perhaps this should be 0?]
    }

    public void noteOn()
    {
        // If we don't have a note on envelope then it is invalid to have 'note on' state,
        // so divert to 'sustain' state
        if (m_noteOnEnvelope == null)
        {
            sustain();
        }
        // Else set 'note on' state and restart the envelope
        else
        {
            m_currentEnvelope = 0;
            m_noteOnEnvelope.restart();
        }
    }

    public void sustain()
    {
        // (If we don't have a sustain envelope then it is still valid to have 'sustain' state)

        // Set 'sustain' state and if we have a sustain envelope then restart it
        m_currentEnvelope = 1;
        if (m_sustainEnvelope != null)
            m_sustainEnvelope.restart();
    }

    public void noteOff()
    {
        // If we don't have a note off envelope then it is invalid to have 'note off' state,
        // so divert to 'end' state
        if (m_noteOffEnvelope != null)
        {
            m_currentEnvelope = 2;
            m_noteOffEnvelope.restart();
        }
        else
        {
            end();
        }
    }

    public void end()
    {
        // Set 'end' state
        m_currentEnvelope = 3;
    }

    public boolean ended()
    {
        return m_currentEnvelope == 3;
    }

    // + }}}

    // + Run {{{

    private float m_currentAmplitude;

    public float play()
    {
        switch (m_currentEnvelope)
        {
        case 0:
            //if (m_noteOnEnvelope != null)
            //{
                m_currentAmplitude = m_noteOnEnvelope.play();
                if (m_noteOnEnvelope.ended())
                    sustain();
            //}
            break;

        case 1:
            // If we have a sustain envelope then play it, else keep current amplitude unchanged
            if (m_sustainEnvelope != null)
            {
                m_currentAmplitude = m_sustainEnvelope.play();
                if (m_sustainEnvelope.ended())
                    noteOff();
            }
            break;

        case 2:
            //if (m_noteOffEnvelope != null)
            //{
                m_currentAmplitude = m_noteOffEnvelope.play();
                if (m_noteOffEnvelope.ended())
                    end();
            //}
            break;
        }

        //
        return m_currentAmplitude;
    }

    // + }}}
}
