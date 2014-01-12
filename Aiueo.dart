import 'dart:html';

class Camera {
  
  VideoElement localVideo;
  CanvasElement localCanvas;
  CanvasRenderingContext2D ctx2;
  ImageData prevImg = null;
  final int threshold = 3200000;
  
  void run() {
    localVideo = document.querySelector('#selfView');
    localCanvas = document.querySelector('#localCanvas');
    ctx2 = localCanvas.getContext('2d');
    startCamera();
    
  }
  
  bool flg = false;
  void bossIsHere() {
    if (flg == false) {
      document.querySelector('#cover').style.visibility = 'visible';
      flg = true;
    }
  }
  
  void startCamera() {
    window.navigator.getUserMedia(audio: true, video: true).then(gotStream);
  }
  
  void gotStream(stream) {
    localVideo.src = Url.createObjectUrlFromStream(stream);
    startCanvasCopy();
  }

  void startCanvasCopy() {
    canvasCopy(100);
  }
  
  bool canvasCopy(num highResTime) {
    renderCanvas();
    window.requestAnimationFrame(canvasCopy);
  }
  
  int checkDiff(ImageData prev, ImageData img) {
    List<int> pix = img.data;
    List<int> prevPix = prev.data;
    int result = 0;
    for (int i = 0, n = pix.length; i < n; i += 4) {
      int diffR = pix[i] - prevPix[i];
      int diffG = pix[i] - prevPix[i + 1];
      int diffB = pix[i] - prevPix[i + 2];
      result += diffR.abs() + diffG.abs() + diffB.abs();
    }
    return result;
  }

  void binaryImage(ImageData img) {
    List<int> pix = img.data;
    for (int i = 0, n = pix.length; i < n; i += 4) {
      num color = (pix[i  ] + pix[i+1] + pix[i+2]) / 3;
      color = (color > 100) ? 255 : 0;
      pix[i  ] = color; // red
      pix[i+1] = color; // green
      pix[i+2] = color; // blue
      // i+3 is alpha (the fourth element)
    }
  }
  
  int prevDiff = 0;
  
  void renderCanvas() {
    ctx2.drawImageScaled(localVideo, 0, 0, 200, 150);
    ImageData imgd = ctx2.getImageData(0, 0, localCanvas.width, localCanvas.height);
    binaryImage(imgd);
    if (prevImg != null) {
      int diff = checkDiff(prevImg, imgd);
      if (prevDiff > 0 && diff > threshold) {
        document.querySelector('#status').innerHtml = 'Boss is detected！' + diff.toString();
        bossIsHere();
      } else {
        prevDiff = diff;
      }
      print('diff = ' + diff.toString());
    }
    prevImg = imgd;
    ctx2.putImageData(imgd, 0, 0);
  }
}

void main() {
  new Camera().run();
}
