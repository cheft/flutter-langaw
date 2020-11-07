import 'dart:ui';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:langaw/components/fly.dart';
import 'package:langaw/components/backyard.dart';
import 'package:langaw/components/housefly.dart';
import 'package:langaw/components/agilefly.dart';
import 'package:langaw/components/droolerfly.dart';
import 'package:langaw/components/hungryfly.dart';
import 'package:langaw/components/machofly.dart';
import 'package:langaw/view.dart';
import 'package:langaw/views/home.dart';
import 'package:langaw/components/startbtn.dart';
import 'package:langaw/views/lost.dart';
import 'package:langaw/components/credits.dart';
import 'package:langaw/components/help.dart';
import 'package:langaw/views/help.dart';
import 'package:langaw/views/credits.dart';
import 'package:langaw/components/score.dart';

class LangawGame extends Game {
  Size screenSize;
  double tileSize;
  Backyard backyard;
  List<Fly> flies;
  Random rnd;

  View activeView = View.home;
  HomeView homeView;
  LostView lostView;
  HelpView helpView;
  CreditsView creditsView;
  
  StartButton startButton;
  HelpButton helpButton;
  CreditsButton creditsButton;
  ScoreDisplay scoreDisplay;

  bool isHandled = false;
  bool didHitAFly = true;

  int score;

  LangawGame() {
    initialize();
  }

  void initialize() async {
    resize(await Flame.util.initialDimensions());
    backyard = Backyard(this);
    homeView = HomeView(this);
    lostView = LostView(this);
    helpView = HelpView(this);
    creditsView = CreditsView(this);
    startButton = StartButton(this);
    helpButton = HelpButton(this);
    creditsButton = CreditsButton(this);
    scoreDisplay = ScoreDisplay(this);

    flies = List<Fly>();
    rnd = Random();
  }

  void render(Canvas canvas) {
    Rect bgRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint bgPaint = Paint();
    bgPaint.color = Color(0xff576574);
    canvas.drawRect(bgRect, bgPaint);
    backyard.render(canvas);
    flies.forEach((Fly fly) => fly.render(canvas));

    if (activeView == View.home || activeView == View.lost) {
      startButton.render(canvas);
      helpButton.render(canvas);
      creditsButton.render(canvas);
    }

    if (activeView == View.playing) {
      scoreDisplay.render(canvas);
    } else if (activeView == View.home) {
      homeView.render(canvas);
    } else if (activeView == View.lost) {
      lostView.render(canvas);
    } else if (activeView == View.help) {
      helpView.render(canvas);
    } else if (activeView == View.credits) {
      creditsView.render(canvas);
    }
  }


  void update(double t) {
    backyard.update(t);
    if (flies.length == 0) {
      spawnFly();
    }
    flies.forEach((Fly fly) => fly.update(t));
    flies.removeWhere((Fly fly) => fly.isOffScreen);

    if (activeView == View.playing) scoreDisplay.update(t);
  }

  void resize(Size size) {
    screenSize = size;
    tileSize = screenSize.width / 9;
  }

  void onTapDown(TapDownDetails d) {
    isHandled = false;
    if (!isHandled && startButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        startButton.onTapDown();
        isHandled = true;
      }
    } else {
      didHitAFly = false;
    }

    flies.forEach((Fly fly) {
      if (fly.flyRect.contains(d.globalPosition)) {
        fly.onTapDown();
        isHandled = true;
        didHitAFly = true;
      }
    });

    if (activeView == View.playing && !didHitAFly) {
      activeView = View.lost;
    }

    // 教程按钮
    if (!isHandled && helpButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        helpButton.onTapDown();
        isHandled = true;
      }
    }

    // 感谢按钮
    if (!isHandled && creditsButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        creditsButton.onTapDown();
        isHandled = true;
      }
    }

    if (!isHandled) {
      if (activeView == View.help || activeView == View.credits) {
        activeView = View.home;
        isHandled = true;
      }
    }
  }

  void spawnFly() {
    double x = rnd.nextDouble() * (screenSize.width - (tileSize * 2.025));
    double y = rnd.nextDouble() * (screenSize.height - (tileSize * 2.025));

    switch (rnd.nextInt(5)) {
    case 0:
      flies.add(HouseFly(this, x, y));
      break;
    case 1:
      flies.add(DroolerFly(this, x, y));
      break;
    case 2:
      flies.add(AgileFly(this, x, y));
      break;
    case 3:
      flies.add(MachoFly(this, x, y));
      break;
    case 4:
      flies.add(HungryFly(this, x, y));
      break;
    }
  }
}
