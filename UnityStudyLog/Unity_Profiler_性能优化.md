## 性能优化



#### 游戏性能简述

提起游戏性能，首先要提到的就是，不仅开发人员，所有游戏玩家都应该会接触到的一个名词：帧率（Frame rate）。

帧率是衡量游戏性能的基本指标。在游戏中，“一帧”便是是绘制到屏幕上的一个静止画面。绘制一帧到屏幕上也叫做渲染一帧。每秒的帧数(fps)或者说帧率表示GPU处理时每秒钟能够更新的次数。高的帧率可以得到更流畅、更逼真的动画。

现阶段大多数游戏的理想帧率是60FPS，其带来的交互感和真实感会更加强烈。通常来说，帧率在30FPS以上都是可以接受的，特别是对于不需要快速反应互动的游戏，例如休闲、解密、冒险类游戏等。有些项目有特殊的需求，比如VR游戏，至少需要90FPS。当帧率降低到30FPS以下时，玩家通常会有不好的体验。

但在游戏中重要的不仅仅帧率的速度，帧率同时也必须非常稳定。玩家通常对帧率的变化比较敏感，不稳定的帧率通常会比低一些但是很稳定的帧率表现更差。

虽然帧率是一个我们谈论游戏性能的基本标准，但是当我们提升游戏性能时，更因该想到的是渲染一帧需要多少毫秒。帧率的相对改变在不同范围会有不同的变化。比如，从60到50FPS呈现出的是额外3.3毫秒的运行时间，但是从30到20FPS呈现出的是额外的16.6毫秒的运行时间。在这里，同样降低了10FPS，但是渲染一帧上时间的差别是很显著的。

我们还需要了解渲染一帧需要多少毫秒才能满足当前帧率。通过公式 1000/（想要达到的帧率）。通过这个公式可以得到，30FPS必须在33.3毫秒之内渲染完一帧，60FPS必须在16.6毫秒内渲染完一帧。

渲染一帧，Unity需要执行很多任务。比如，Unity需要更新游戏的状态。有一些任务在每一帧都需要执行，包括执行脚本，运行光照计算等。除此之外，有许多操作是在一帧执行多次的，例如物理运算。当所有这些任务都执行的足够快时，我们的游戏才会有稳定且理想的帧率。当这些任务执行不满足需求时，渲染一帧将花费更多的时间，并且帧率会因此下降。

知道哪些任务花费了过多的时间，是游戏性能问题的关键。一旦我们知道了哪些任务降低了帧率，便可以尝试优化游戏的这一部分。这就是为什么性能分析工具是游戏优化的重点之一。

