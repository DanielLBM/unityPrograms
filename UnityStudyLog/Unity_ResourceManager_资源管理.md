#### 正确的利用Unity资源管理的好处：

1. 高效的管理资源
2. 合理的分配内存(避免不必要的内存开销 — 比如同一个Asset被打包到多个AssetBundle里，然后分别被游戏加载)
3. 做到增量更新(无需下载更新整个游戏程序，通过Patch的形式动态更新部分游戏内容)

4. 以最少及最合理的方式减少程序大小(避免所有资源一次性打到游戏程序里)

5. 帮助快速开发(动态和静态的资源方式合理利用，高效开发)


可以看出Resources下的资源文件并没有被打包到图集里，而是作为单独的Texture2D资源存在。
同时没有放置在Resources目录下的资源，如果没有被游戏使用，最终是不会被打包到游戏里(反之放在Resources目录下即使未被使用也会被打包到游戏里)。


但Unity官网讲解提到的我们应该尽量去避免使用Resources。
原因如下：

1. 
   Use of the Resources folder makes fine-grained memory management more difficult.(使用Resources folder会使内存管理更困难)

2. Improper use of Resources folders will increase application startup time and the length of builds.(不合理的使用Resources folders会使程序启动和编译时间变长)

3. As the number of Resources folders increases, management of the Assets within those folders becomes very difficult.(随着Resources folders数量的增加，Assets管理越来越困难)

4. The Resources system degrades a project’s ability to deliver custom content to specific platforms and eliminates the possibility of incremental content upgrades.(Resources System降低了项目对于各平台和资源的动态更新能力，因为Resources目录下的资源无论如何都会被打包到游戏程序里)
   AssetBundle Variants are Unity’s primary tool for adjusting content on a per-device basis.(AssetBundle是Unity针对设备动态更新的主要工具)



#### 谈谈Unity的资源管理

- 在Unity最佳实践明确指出, 要使用AssetBundle而不是Resources目录来管理资源。然而，事情并不像Unity官方描述的那么美好。因为使用AssetBundle我们甚至无法实现一个高效易用的，完全自动化资源管理方案。

- 据Unity官方说，一般有两种方案。

  方案一，如果你的游戏是关卡性质的，可以在一个关卡里加载所有AssetBundle，然后在进入下一关卡时，卸载本关卡中加载的所有AssetBundle. 但这种机制似乎只对愤怒的小鸟这种小游戏才适用吧:D。

  方案二，如果你的游戏不是关卡类的，那么Unity推荐做一个资源对AssetBundle引用计数。

- 如果一个对象（Asset或其他AssetBundle)引用此AssetBundle则其引用计数加1. 如果此AssetBundle首次加载（即加载前引用计数为0), 还需要递归对其依赖引用计数加1。

- 如果一个AssetBundle的引用计数为0则释放这个AssetBundle，同时还需要递归对其依赖引用计数减1

- 除非，我们做像愤怒小鸟一样的通关游戏，不然似乎只有方案二给我们用。而且方案二乍一看是完备的，因为这正是GC算法的一种实现。


https://blog.gotocoding.com/archives/1262