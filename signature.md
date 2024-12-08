# 签名流程

1. 签名
```bash
codesign --force --deep --sign "dice" ./DiceGenerator-Bundle/dice.app 
```

2. 校验
```bash
codesign --verify --deep --strict ./DiceGenerator-Bundle/dice.app 
```

3. dmg制作
```bash
ln -s /Applications "./DiceGenerator-Bundle/Applications"

hdiutil create -volname "Dice Generator" \
               -srcfolder DiceGenerator-Bundle \
               -ov -format UDZO \
               DiceGenerator.dmg
```