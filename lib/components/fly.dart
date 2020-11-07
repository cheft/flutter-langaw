import 'dart:ui';
import 'package:langaw/game.dart';
import 'package:flame/sprite.dart';
import 'package:langaw/view.dart';

class Fly {
  final LangawGame game;
  Rect flyRect;
  bool isDead = false;
  bool isOffScreen = false;

  List flyingSprite;
  Sprite deadSprite;
  double flyingSpriteIndex = 0;

  double get speed => game.tileSize * 3;
  Offset targetLocation;

  Fly(this.game, double x, double y) {
    setTargetLocation();
  }

  void render(Canvas c) {
    if (isDead) {
      deadSprite.renderRect(c, flyRect.inflate(2));
    } else {
      // TODO:
      flyingSprite[flyingSpriteIndex.toInt()].renderRect(c, flyRect.inflate(2));
    }
  }

  void update(double t) {
    if (isDead) {
      flyRect = flyRect.translate(0, game.tileSize * 12 * t);
    } else {
      // flyingSpriteIndex += 30 * t;
      // print(flyingSpriteIndex);
      // if (flyingSpriteIndex >= 2) {
      //   flyingSpriteIndex -= 2;
      // }
      if (flyingSpriteIndex == 1) {
        flyingSpriteIndex = 0;
      } else {
        flyingSpriteIndex = 1;
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
  }

  void onTapDown() {
    if (!isDead) {
      isDead = true;
      if (game.activeView == View.playing) {
        game.score += 1;
      }
    }
  }

  void setTargetLocation() {
    double x = game.rnd.nextDouble() * (game.screenSize.width - (game.tileSize * 2.025));
    double y = game.rnd.nextDouble() * (game.screenSize.height - (game.tileSize * 2.025));
    targetLocation = Offset(x, y);
  }
}
