class Button {

  int x;
  int y;
  int w;
  int h;
  String text;

  Button(int x, int y, int w, int h, String text) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.text = text;
  }

  void draw() {
    pushStyle();

    textAlign(CENTER, CENTER);
    textSize(40);
    
    // shadow
    fill(155);
    rect(x-5, y, w, h);
    
    // button
    fill(255);
    rect(x, y, w, h);

    if (mouseOn()) { 
      fill(255, 0, 0);
    } else { 
      fill(50);
    }
    text(text, x, y-5);

    popStyle();
  }

  boolean mouseOn() {
    return (x - (w/2) < mouseX && mouseX < x + (w/2) && y - (h/2) < mouseY && mouseY < y + (h/2));
  }
}

