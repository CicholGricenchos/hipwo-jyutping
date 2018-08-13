# jyutping_triple
一个26键粤拼三拼方案

键位图
======
![keyboard-layout](http://cichol.qiniudn.com/keyboard-layout.png)

其中每个键的第一、二、三行，分别为声母、韵腹，韵尾。

例要输入 `paai deoi gaai saan`，使用三拼将为`phi dvi ghi shn`。

对于无声母的拼音，需要额外输入零声母，即重复一次韵母，如`uk`应输入为`uuk`。

需要输入零声母的情况：
```
a => aa
aa => xx
o => oo
u => uu
ng => nn
m => mm
```

目前声母部分已经大致排完，但韵腹与韵尾部分尚有很大优化空间，可利用多余空间进行冗余。如果有建议，欢迎提交issue。
