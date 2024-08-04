## 对象池

#### 什么是对象池

为了方便对象的产生和回收，我们使用一个集合来存储不使用对象，当需要使用该对象时，从集合中取出来，不用时不进行销毁，而是将其取消激活，重新存入对象池中。

#### 为什么要使用对象池

当一个游戏需要频繁的创建和销毁对象时，为了不增加GC的性能消耗，可以考虑使用回收对象来达到复用的目的。（适用于频繁创建和销毁的对象）


注：对象池是一种用内存换运存的优化技术，只有大量频繁创建和销毁的对象使用对象池，才能起到优化作用，否则不具有优化效果。
原文链接：https://blog.csdn.net/qq_38721111/article/details/81206735

#### 为什么使用对象池

游戏制作避免不了做游戏优化，让游戏达到60分容易，但从60分到90分就是一个漫长的优化路程，因此提前接触到优化的知识在游戏开发设计的时候就能规避很多坑点（说是接触而不是开展优化是因为项目初期功能不明确，做太多优化的功能其实是没有意义的）。

例如游戏中会经常用到很多个相同类型的物体，比如子弹特效，比如一个UI的背包。如果每次要用的时候都去创建用完就删除掉，会造成频繁的资源回收（GC），部分游戏玩着玩着就卡顿就源于此。

对象池是一种设计模式，是一种游戏经常用到的脚本类型，了解对象池对游戏性能优化非常有帮助。

#### 对象池初识


对象池的核心思想是：预先初始化一组可重用的实体，而不是按需销毁然后重建 

注：资源保存在“池”中，外部表现无非是Item物体修改了父物体，然后关闭激活，这是非常简单的操作

当再打开界面的时候，因为池中有资源，所以就跳过了读取资源实例化的步骤（资源加载和实例化是最消耗性能的）。

这里有必要强调的是，我们没必要单独去做第一次对象池的实例化，我们只需要知道，这个物体是重复的，所以这个物体我们都在对象池中去取。而对象池也只关注，当别人调用了我的创建实例函数，我必须返回给它一个创建好的物体，而池子里面有没有资源让对象池自己判断，如果没有则创建，如果有则直接拿出来给它，这种设计方法叫做空池触发

作者：皮皮关做游戏 https://www.bilibili.com/read/cv54304 出处：bilibili 

#### 对象池的实现

Pool(对象池)：对存储对象的集合进行了适当的封装，用于单个游戏对象（预制体）的回收和复用。

```c#
public class Pool{
public string name = "";
 
public GameObject prefab;
 
Queue<GameObject> poolQueue = new Queue<GameObject>(); //使用队列存储对象池中的数据
 
//立即回收
public void Recycle(GameObject go)
{
    go.GetComponent<IReset>().Reset();
 
    go.SetActive(false);
    poolQueue.Enqueue(go);
}
 
//延迟回收
public IEnumerator AutoRecycle(GameObject go, float delay)
{
    //使用写成，延时回收
    yield return new WaitForSeconds(delay);
 
    Recycle(go);
}
 
//创建对象
public GameObject Create()
{
    GameObject go = null;
    if (poolQueue.Count > 0)
    {
        //对象池中有需要创建的对象，从对象池中取
        go = poolQueue.Dequeue();
        go.SetActive(true);
    }
    else
    {
        //当对象池中没有需要创建的对象时，创建对象
        go = GameObject.Instantiate(prefab);
    }
    return go;
}
}
```
PoolMgr(对象池管理器)：对对象池进行了进一步的封装，可以用于创建多个对象（预制体）的回收和服用，可以更加方便的使用对象池。（对象池模块化）。

代码：



```c#
public class PoolMgr : MonoBehaviour {
public Pool[] pools;
 
//对象池管理器使用单例
private static PoolMgr _instance;
public static PoolMgr Instance {
 
    get {
        return _instance;
    }
}
 
void Awake() {
    if (_instance == null)
    {
        _instance = this;
    }
    else
    {
        Destroy(this.gameObject);
    }
}
 
//将对象池注册进字典
Dictionary<string, Pool> poolDir = new Dictionary<string, Pool>();
void Start () {
    foreach (var item in pools)
    {
        poolDir.Add(item.name.ToLower(), item);
    }
}
 
public GameObject CreateObj(string poolName)
{
    Pool pool;
    //TryGetValue获取与键相关联的值
    if (poolDir.TryGetValue(poolName.ToLower(),out pool))
    {
        return pool.Create();
    }
 
    Debug.LogError(poolName + "不存在");
    return null;
}
 
/// <summary>
/// 立即回收
/// </summary>
 
public void RecycleObjs(string poolName, GameObject go)
{
    Pool pool;
    if (poolDir.TryGetValue(poolName.ToLower(),out pool))
    {
        pool.Recycle(go);
    }
}
/// <summary>
/// 延迟销毁
/// </summary>
/// <param name="poolName">对象池名字</param>
/// <param name="go">需要回收的对象</param>
/// <param name="delay">延迟时间</param>
public void RecycleObjs(string poolName, GameObject go, float delay)
{
    StartCoroutine(DelayRecycle(poolName, go, delay));
}
 
IEnumerator DelayRecycle(string poolName, GameObject go, float delay)
{
    //延迟调用的立即回收
    yield return new WaitForSeconds(delay);
 
    Pool pool;
    if (poolDir.TryGetValue(poolName.ToLower(),out pool))
    {
        pool.Recycle(go);
    }
}
}
```

链接：https://blog.51cto.com/u_15273495/3230261

#### 对象池的创建时机：

过早创建对象池，池中的对象会占用大量内存。若等到游戏使用对象时再创建对象池，可能因为大量实例化造成掉帧。所以，我认为在Loading界面创建下一个场景需使用的对象池是较为合理的。比如天天飞车中的NPC车，金币，赛道，在进入单局比赛后才用到。可以在进入比赛的Loading界面预先创建金币，NPC车，赛道的对象池，比赛中直接申请使用。

