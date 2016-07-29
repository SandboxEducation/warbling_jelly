public interface IEnvelope
{
    public float play();
    public boolean ended();
    public void restart();

    public IEnvelope scaleTimesBy(float i_scalingFactor);
}