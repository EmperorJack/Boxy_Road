class BasicTween {
  float startValue;
  float animationLength;
  float valueRange;
  float startTime;

  BasicTween(float startValue, float animationLength, float valueRange, float startTime) {
    this.startValue = startValue;
    this.animationLength = animationLength;
    this.valueRange = valueRange;
    this.startTime = startTime;
  }  

  float tween(float time) {
    float currentTime = time - startTime;
    float t = norm(currentTime, 0, animationLength);
    t = constrain(t, 0.0, 1.0);
    float val = lerp(startValue, startValue + valueRange, t);
    return val;
  }
}
