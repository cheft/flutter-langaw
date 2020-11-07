import 'dart:ui';
import 'package:langaw/game.dart';
import 'package:flame/sprite.dart';
import 'package:langaw/view.dart';
import 'package:langaw/components/callout.dart';
import 'package:flame/flame.dart';

class Fly {
  final LangawGame game;
  Callout callout;
  
  Rect flyRect;
  bool isDead = false;
  bool isOffScreen = false;

  List flyingSprite;
  Sprite deadSprite;
  double flyingSpriteIndex = 0;
  int calloutIndex = 0;

  double get speed => game.tileSize * 3;
  int score = 1;
  Offset targetLocation;

  Fly(this.game, double x, double y) {
    setTargetLocation();
    callout = Callout(this);
  }

  void render(Canvas c) {
    if (isDead) {
      deadSprite.renderRect(c, flyRect.inflate(2));
    } else {
      // TODO:
      flyingSprite[flyingSpriteIndex.toInt()].renderRect(c, flyRect.inflate(2));
    }

    if (game.activeView == View.playing) {
      callout.render(c);
    }
  }

  void update(double t) {
    if (isDead) {
      flyRect = flyRect.translate(0, game.tileSize * 12 * t);
    } else {
      // TODO 有bug
      // flyingSpriteIndex += 30 * t;
      // print(flyingSpriteIndex);
      // if (flyingSpriteIndex >= 2) {
      //   flyingSpriteIndex -= 2;
      // }
      
      if (calloutIndex % 4 == 0) {
        flyingSpriteIndex = 0;
      } else {
        flyingSpriteIndex = 1;
      }
      if (calloutIndex >= 8) {
        calloutIndex = 0;
      } else {
        calloutIndex += 1;
      }

      // TODO: 解析
      double stepDistance = speed * t;
      Offset toTarget = targetLocation - Offset(flyRect.left, flyRect.top);
      if (stepDistance < toTarget.distance) {
        Offset stepToTarget = Offset.fromDirection(toTarget.direction, stepDistance);
        flyRect = flyRect.shift(stepToTarget);
      } else {
        flyRect = flyRect.shift(toTarget);
        setTargetLocation();
      }
    }

    if (flyRect.top > game.screenSize.height) {
      isOffScreen = true;
    }

    callout.update(t);
  }

  void onTapDown() {
    if (!isDead) {
      if (game.soundButton.isEnabled) {
        Flame.audio.play('sfx/ouch' + (game.rnd.nextInt(11) + 1).toString() + '.ogg');
      }
      isDead = true;
      if (game.activeView == View.playing) {
        game.score += this.score;

        if (game.score > (game.storage.getInt('highscore') ?? 0)) {
          game.storage.setInt('highscore', game.score);
          game.highscoreDisplay.updateHighscore();
        }
      }
    }
  }

  void setTargetLocation() {
    double x = game.rnd.nextDouble() * (game.screenSize.width - (game.tileSize * 2.025));
    double y = game.rnd.nextDouble() * (game.screenSize.height - (game.tileSize * 2.025));
    targetLocation = Offset(x, y);
  }
}
