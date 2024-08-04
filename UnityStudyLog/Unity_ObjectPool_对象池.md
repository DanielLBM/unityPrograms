## �����

#### ʲô�Ƕ����

Ϊ�˷������Ĳ����ͻ��գ�����ʹ��һ���������洢��ʹ�ö��󣬵���Ҫʹ�øö���ʱ���Ӽ�����ȡ����������ʱ���������٣����ǽ���ȡ��������´��������С�

#### ΪʲôҪʹ�ö����

��һ����Ϸ��ҪƵ���Ĵ��������ٶ���ʱ��Ϊ�˲�����GC���������ģ����Կ���ʹ�û��ն������ﵽ���õ�Ŀ�ġ���������Ƶ�����������ٵĶ���


ע���������һ�����ڴ滻�˴���Ż�������ֻ�д���Ƶ�����������ٵĶ���ʹ�ö���أ��������Ż����ã����򲻾����Ż�Ч����
ԭ�����ӣ�https://blog.csdn.net/qq_38721111/article/details/81206735

#### Ϊʲôʹ�ö����

��Ϸ�������ⲻ������Ϸ�Ż�������Ϸ�ﵽ60�����ף�����60�ֵ�90�־���һ���������Ż�·�̣������ǰ�Ӵ����Ż���֪ʶ����Ϸ������Ƶ�ʱ����ܹ�ܺܶ�ӵ㣨˵�ǽӴ������ǿ�չ�Ż�����Ϊ��Ŀ���ڹ��ܲ���ȷ����̫���Ż��Ĺ�����ʵ��û������ģ���

������Ϸ�лᾭ���õ��ܶ����ͬ���͵����壬�����ӵ���Ч������һ��UI�ı��������ÿ��Ҫ�õ�ʱ��ȥ���������ɾ�����������Ƶ������Դ���գ�GC����������Ϸ�������žͿ��پ�Դ�ڴˡ�

�������һ�����ģʽ����һ����Ϸ�����õ��Ľű����ͣ��˽����ض���Ϸ�����Ż��ǳ��а�����

#### ����س�ʶ


����صĺ���˼���ǣ�Ԥ�ȳ�ʼ��һ������õ�ʵ�壬�����ǰ�������Ȼ���ؽ� 

ע����Դ�����ڡ��ء��У��ⲿ�����޷���Item�����޸��˸����壬Ȼ��رռ�����Ƿǳ��򵥵Ĳ���

���ٴ򿪽����ʱ����Ϊ��������Դ�����Ծ������˶�ȡ��Դʵ�����Ĳ��裨��Դ���غ�ʵ���������������ܵģ���

�����б�Ҫǿ�����ǣ�����û��Ҫ����ȥ����һ�ζ���ص�ʵ����������ֻ��Ҫ֪��������������ظ��ģ���������������Ƕ��ڶ������ȥȡ���������Ҳֻ��ע�������˵������ҵĴ���ʵ���������ұ��뷵�ظ���һ�������õ����壬������������û����Դ�ö�����Լ��жϣ����û���򴴽����������ֱ���ó���������������Ʒ��������ճش���

���ߣ�ƤƤ������Ϸ https://www.bilibili.com/read/cv54304 ������bilibili 

#### ����ص�ʵ��

Pool(�����)���Դ洢����ļ��Ͻ������ʵ��ķ�װ�����ڵ�����Ϸ����Ԥ���壩�Ļ��պ͸��á�

```c#
public class Pool{
public string name = "";
 
public GameObject prefab;
 
Queue<GameObject> poolQueue = new Queue<GameObject>(); //ʹ�ö��д洢������е�����
 
//��������
public void Recycle(GameObject go)
{
    go.GetComponent<IReset>().Reset();
 
    go.SetActive(false);
    poolQueue.Enqueue(go);
}
 
//�ӳٻ���
public IEnumerator AutoRecycle(GameObject go, float delay)
{
    //ʹ��д�ɣ���ʱ����
    yield return new WaitForSeconds(delay);
 
    Recycle(go);
}
 
//��������
public GameObject Create()
{
    GameObject go = null;
    if (poolQueue.Count > 0)
    {
        //�����������Ҫ�����Ķ��󣬴Ӷ������ȡ
        go = poolQueue.Dequeue();
        go.SetActive(true);
    }
    else
    {
        //���������û����Ҫ�����Ķ���ʱ����������
        go = GameObject.Instantiate(prefab);
    }
    return go;
}
}
```
PoolMgr(����ع�����)���Զ���ؽ����˽�һ���ķ�װ���������ڴ����������Ԥ���壩�Ļ��պͷ��ã����Ը��ӷ����ʹ�ö���ء��������ģ�黯����

���룺



```c#
public class PoolMgr : MonoBehaviour {
public Pool[] pools;
 
//����ع�����ʹ�õ���
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
 
//�������ע����ֵ�
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
    //TryGetValue��ȡ����������ֵ
    if (poolDir.TryGetValue(poolName.ToLower(),out pool))
    {
        return pool.Create();
    }
 
    Debug.LogError(poolName + "������");
    return null;
}
 
/// <summary>
/// ��������
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
/// �ӳ�����
/// </summary>
/// <param name="poolName">���������</param>
/// <param name="go">��Ҫ���յĶ���</param>
/// <param name="delay">�ӳ�ʱ��</param>
public void RecycleObjs(string poolName, GameObject go, float delay)
{
    StartCoroutine(DelayRecycle(poolName, go, delay));
}
 
IEnumerator DelayRecycle(string poolName, GameObject go, float delay)
{
    //�ӳٵ��õ���������
    yield return new WaitForSeconds(delay);
 
    Pool pool;
    if (poolDir.TryGetValue(poolName.ToLower(),out pool))
    {
        pool.Recycle(go);
    }
}
}
```

���ӣ�https://blog.51cto.com/u_15273495/3230261

#### ����صĴ���ʱ����

���紴������أ����еĶ����ռ�ô����ڴ档���ȵ���Ϸʹ�ö���ʱ�ٴ�������أ�������Ϊ����ʵ������ɵ�֡�����ԣ�����Ϊ��Loading���洴����һ��������ʹ�õĶ�����ǽ�Ϊ����ġ���������ɳ��е�NPC������ң��������ڽ��뵥�ֱ�������õ��������ڽ��������Loading����Ԥ�ȴ�����ң�NPC���������Ķ���أ�������ֱ������ʹ�á�

