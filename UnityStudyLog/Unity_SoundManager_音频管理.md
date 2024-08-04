## SoundManager音频管理

#### 声音的要素

1. 音频文件AudioClip
2. 音源AudioSource
3. 耳朵AudioListener;//全局只能有一个
4. 2D/3D音频;//2D只是简单地播放声音，3D可以根据距离衰减音量

#### 怎样听到声音：

创建一个节点，挂载AudioSource组件，AudioSource组件关联AudioClip属性，设置声音是否一开始就加载播放play on awake，是否循环播放，2D还是3D

场景中有一个节点有AudioListener组件，挂载AudioListener组件的节点在挂载AudioSource组件节点的声音范围内。运行，可以听到声音。 

#### 音乐与音效管理

1.  游戏里面一般分为音乐与音效;
2. 音乐指的是游戏的背景音乐;
3. 音效是游戏中的较短的音乐，来配合游戏的动作等;
4. Unity游戏没有音乐和音效之分，都是AudioSource + AudioClip;
5. 2D音效没有衰减,所以与位置没有关系;
6. 3D音效需要有声音所在节点的位置;
7. 游戏需求需要音乐和音效分开设置，开启和关闭;

#### SoundManager脚本

首先，声音包括音乐和音效，我们分两大块来管理，音乐为一块，音效为一块，这个块实际上Unity内部是不分的，但是我们来分，

用字典数据类型保存URL和音源AudioSource之间的对应关系，两个表，一个是音乐的，一个是音效的。

有了这两个表，这样如果我们要禁止背景音乐就去遍历音乐表，如果我们要禁止音效就去遍历音效表。

播放一个音效，需要new一个物体，在这个物体上加音源AudioSource组件，关联好音频文件AudioClip，这样就会播放出一个音效，

播放出来的音效会有分2D和3D，2D随便放在哪里，3D需要管理，有一个位置，所以加一个播放3D音效的接口。

1: 全局唯一的sound_manager;

2: 在场景里面创建一个物体(做为声音的根节点)，而且设置这个物体场景切换也不会删除;

3: 编写接口播放背景音乐play_music;

4: 编写接口播放背景音效play_effect; // 2D声音

5: 音乐和音效内部实现都是一样的, 只不过要把url分组管理, 音效为一组，音乐为一组;

6: 提供开关音效接口set_mute(),并将值写入本地，下一次打开游戏的时候会读取这个值，维持上一次的设置。

7: 提供开关背景音乐接口switch_music(),并将值写入本地，下一次打开游戏的时候会读取这个值，维持上一次的设置。

8: 添加一个play_effect接口在指定的坐标出访一个声音, 可以用于3D音效;

9: 添加一个接口停止掉背景音乐stop_music(url);

10: 添加一个接口删除掉播放的背景音乐clear_music(url), clear_effect(url);

11: 声音文件来自Resouce还是assetBundle，可以通过资源管理来封装，目前从Resource里面加载;

12: 加一个脚本，每隔0.5秒扫描一次已经播放完的声音组件,将它disable; 

13.声音大小的设置

14.声音的暂停呵呵取消暂停的方法

#### 声音管理实例

1.创建Unity项目工程和文件目录，保存场景

2.在Resources文件夹下创建一个sounds文件夹，把背景音乐Login.mp3和音效Close.mp3（第70）放进去(代码实现的是AB的加载方式)

3.为了统一管理游戏中的声音，写一个脚本SoundManager来管理



#### SoundManager.cs 的code：

```c#
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace Tripeaks.Core
{
    public class SoundManager
    {
        // (1) 声音根节点的物体;
        // (2) 保证这个节点在场景切换的时候不会删除，这样就不用再初始化一次;
        // (3) 所有播放声音的生源节点，都是在这个节点下

        static GameObject sound_play_object;//这个就是根节点
        static bool is_music_mute = false;//存放当前全局背景音乐是否静音的变量
        static bool is_effect_mute = false;//存放当前音效是否静音的变量

        static float bgmVolumScale = 1f; //背景音乐声音大小比例
        static float effVolumScale = 0.5f; //音效声音大小比例

        // url --> AudioSource 映射, 区分音乐，音效
        static Dictionary<string, AudioSource> musics = null;//音乐表
        static Dictionary<string, AudioSource> effects = null;//音效表

        /// <summary>
        ///初始化
        /// </summary>
        public static void Init()
        {
            sound_play_object = new GameObject("SoundsManager");//初始化根节点
            sound_play_object.AddComponent<SoundScan>();//把声音检测组件挂载到根节点下
            GameObject.DontDestroyOnLoad(sound_play_object);//场景切换的时候不会删除根节点

            //初始化音乐表和音效表
            musics = new Dictionary<string, AudioSource>();
            effects = new Dictionary<string, AudioSource>();

            // 从本地来加载这个开关
            if (PlayerPrefs.HasKey("music_mute"))//判断is_music_mute有没有保存在本地
            {
                int value = PlayerPrefs.GetInt("music_mute");
                is_music_mute = (value == 1);//int转换bool，如果value==1，返回true，否则就是false
            }

            // 从本地来加载这个开关
            if (PlayerPrefs.HasKey("effect_mute"))//判断is_effect_mute有没有保存在本地
            {
                int value = PlayerPrefs.GetInt("effect_mute");
                is_effect_mute = (value == 1);//int转换bool，如果value==1，返回true，否则就是false
            }

            //存储关闭时的音量比例
            if (PlayerPrefs.HasKey("bgmVolumScale"))
                bgmVolumScale = PlayerPrefs.GetFloat("bgmVolumScale");
            if (PlayerPrefs.HasKey("effVolumScale"))
                effVolumScale = PlayerPrefs.GetFloat("effVolumScale");
            //foreach (AudioSource s in musics.Values)
            //{
            //    s.volume = bgmVolumScale;
            //}
        }

        /// <summary>
        /// set the bgm scale [0,1]
        /// </summary>
        /// <param name="scale"></param>
        public void SetBGMVolumScale(float scale)
        {
            bgmVolumScale = scale;
            foreach (AudioSource s in musics.Values)
            {
                s.volume = bgmVolumScale;
                PlayerPrefs.SetFloat("bgmVolumScale", bgmVolumScale);
            }
        }
        /// <summary>
        /// set the soundeff scale [0,1]
        /// </summary>
        /// <param name="scale"></param>
        public void SetEFFVolumScale(float scale)
        {
            effVolumScale = scale;
            foreach (AudioSource s in effects.Values)
            {
                s.volume = effVolumScale;
                PlayerPrefs.SetFloat("effVolumScale", effVolumScale);
            }
        }

        ///获取背景音乐音量0-1
        public float GetBGMVolumScale()
        {
            return bgmVolumScale;
        }

        ///获取音效音量0-1
        public float GetEFFVolumScale()
        {
            return effVolumScale;
        }

        /// <summary>
        /// 播放指定背景音乐的接口
        /// </summary>
        /// <param name="url"></param>
        /// <param name="is_loop"></param>
        public static void Play_music(string url, bool is_loop = true)
        {
            AudioSource audio_source = null;
            if (musics.ContainsKey(url))//判断是否已经在背景音乐表里面了
            {
                audio_source = musics[url];//是就直接赋值过去
            }
            else//不是就新建一个空节点，节点下再新建一个AudioSource组件
            {
                GameObject s = new GameObject(url);//创建一个空节点
                s.transform.parent = sound_play_object.transform;//加入节点到场景中

                audio_source = s.AddComponent<AudioSource>();//空节点添加组件AudioSource
                //AudioClip clip = Resources.Load<AudioClip>(url);//代码加载一个AudioClip资源文件
                AudioClip clip = ResourcesManager.LoadAudioClip(url);

                audio_source.clip = clip;//设置组件的clip属性为clip
                audio_source.loop = is_loop;//设置组件循环播放
                audio_source.playOnAwake = true;//再次唤醒时播放声音
                audio_source.spatialBlend = 0.0f;//设置为2D声音

                musics.Add(url, audio_source);//加入到背景音乐字典中，下次就可以直接赋值了
            }
            audio_source.mute = is_music_mute;
            audio_source.enabled = true;
            audio_source.Play();//开始播放
        }

        /// <summary>
        /// 停止播放指定背景音乐的接口
        /// </summary>
        /// <param name="url"></param>
        public static void Stop_music(string url)
        {
            AudioSource audio_source = null;
            if (!musics.ContainsKey(url))//判断是否已经在背景音乐表里面了
            {
                return;//没有这个背景音乐就直接返回
            }
            audio_source = musics[url];//有就把audio_source直接赋值过去
            audio_source.Stop();//停止播放
        }

        /// <summary>
        /// 停止播放所有背景音乐的接口
        /// </summary>
        public static void Stop_all_music()
        {
            foreach (AudioSource s in musics.Values)
            {
                s.Stop();
            }
        }

        /// <summary>
        /// 删除指定背景音乐和它的节点
        /// </summary>
        /// <param name="url"></param>
        public static void Clear_music(string url)
        {
            AudioSource audio_source = null;
            if (!musics.ContainsKey(url))//判断是否已经在背景音乐表里面了
            {
                return;//没有这个背景音乐就直接返回
            }
            audio_source = musics[url];//有就把audio_source直接赋值过去
            musics[url] = null;//指定audio_source组件清空
            GameObject.Destroy(audio_source.gameObject);//删除掉挂载指定audio_source组件的节点
        }

        /// <summary>
        /// 切换背景音乐静音开关
        /// </summary>
        public static void Switch_music()
        {
            // 切换静音和有声音的状态
            is_music_mute = !is_music_mute;

            //把当前是否静音写入本地
            int value = (is_music_mute) ? 1 : 0;//bool转换int
            PlayerPrefs.SetInt("music_mute", value);

            // 遍历所有背景音乐的AudioSource元素
            foreach (AudioSource s in musics.Values)
            {
                s.mute = is_music_mute;//设置为当前的状态
            }
        }

        /// <summary>
        /// 当我的界面的静音按钮要显示的时候，到底是显示关闭，还是开始状态;
        /// </summary>
        /// <returns></returns>
        public static bool Music_is_off()
        {
            return is_music_mute;
        }

        /// <summary>
        /// 解暂停
        /// </summary>
        /// <param name="url"></param>
        public void UnPauseMusic(string url)
        {
            AudioSource audio_source = null;
            if (!musics.ContainsKey(url))//判断是否已经在背景音乐表里面了
            {
                return;//没有这个背景音乐就直接返回
            }
            audio_source = musics[url];//有就把audio_source直接赋值过去
            audio_source.UnPause();//解暂停播放
        }

        /// <summary>
        /// 暂停声音
        /// </summary>
        /// <param name="url"></param>
        public void PauseMusic(string url)
        {
            AudioSource audio_source = null;
            if (!musics.ContainsKey(url))//判断是否已经在背景音乐表里面了
            {
                return;//没有这个背景音乐就直接返回
            }
            audio_source = musics[url];//有就把audio_source直接赋值过去
            audio_source.Pause();//暂停播放
        }

        ///************接下来开始是音效的接口************////

        /// <summary>
        /// 播放指定音效的接口
        /// </summary>
        public static void Play_effect(string url, bool is_loop = false)
        {
            AudioSource audio_source = null;
            if (effects.ContainsKey(url))//判断是否已经在音效表里面了
            {
                audio_source = effects[url];//是就直接赋值过去
            }
            else//不是就新建一个空节点，节点下再新建一个AudioSource组件
            {
                GameObject s = new GameObject(url);//创建一个空节点
                s.transform.parent = sound_play_object.transform;//加入节点到场景中

                audio_source = s.AddComponent<AudioSource>();//空节点添加组件AudioSource
                // AudioClip clip = Resources.Load<AudioClip>(url);//代码加载一个AudioClip资源文件
                AudioClip clip = ResourcesManager.LoadAudioClip(url);
                audio_source.clip = clip;//设置组件的clip属性为clip
                audio_source.loop = is_loop;//设置组件循环播放
                audio_source.playOnAwake = true;//再次唤醒时播放声音
                audio_source.spatialBlend = 0.0f;//设置为2D声音

                effects.Add(url, audio_source);//加入到音效字典中，下次就可以直接赋值了
            }
            audio_source.mute = is_effect_mute;
            audio_source.enabled = true;
            audio_source.Play();//开始播放
        }

        /// <summary>
        /// 停止播放指定音效的接口
        /// </summary>
        /// <param name="url"></param>
        public static void Stop_effect(string url)
        {
            AudioSource audio_source = null;
            if (!effects.ContainsKey(url))//判断是否已经在音效表里面了
            {
                return;//没有这个背景音乐就直接返回
            }
            audio_source = effects[url];//有就把audio_source直接赋值过去
            audio_source.Stop();//停止播放
        }

        /// <summary>
        /// 停止播放所有音效的接口
        /// </summary>
        public static void Stop_all_effect()
        {
            foreach (AudioSource s in effects.Values)
            {
                s.Stop();
            }
        }

        /// <summary>
        /// 删除指定音效和它的节点
        /// </summary>
        /// <param name="url"></param>
        public static void Clear_effect(string url)
        {
            AudioSource audio_source = null;
            if (!effects.ContainsKey(url))//判断是否已经在音效表里面了
            {
                return;//没有这个音效就直接返回
            }
            audio_source = effects[url];//有就把audio_source直接赋值过去
            effects[url] = null;//指定audio_source组件清空
            GameObject.Destroy(audio_source.gameObject);//删除掉挂载指定audio_source组件的节点
        }

        /// <summary>
        /// 切换音效静音开关
        /// </summary>
        public static void Switch_effect()
        {
            // 切换静音和有声音的状态
            is_effect_mute = !is_effect_mute;

            //把当前是否静音写入本地
            int value = (is_effect_mute) ? 1 : 0;//bool转换int
            PlayerPrefs.SetInt("effect_mute", value);

            // 遍历所有音效的AudioSource元素
            foreach (AudioSource s in effects.Values)
            {
                s.mute = is_effect_mute;//设置为当前的状态
            }
        }

        /// <summary>
        /// 当我的界面的静音按钮要显示的时候，到底是显示关闭，还是开始状态;
        /// </summary>
        /// <returns></returns>
        public static bool Effect_is_off()
        {
            return is_effect_mute;
        }

        /// <summary>
        /// 播放3D的音效
        /// </summary>
        /// <param name="url"></param>
        /// <param name="pos"></param>
        /// <param name="is_loop"></param>
        public static void Play_effect3D(string url, Vector3 pos, bool is_loop = false)
        {
            AudioSource audio_source = null;
            if (effects.ContainsKey(url))
            {
                audio_source = effects[url];
            }
            else
            {
                GameObject s = new GameObject(url);
                s.transform.parent = sound_play_object.transform;
                s.transform.position = pos;//3D音效的位置

                audio_source = s.AddComponent<AudioSource>();
                // AudioClip clip = Resources.Load<AudioClip>(url);
                AudioClip clip = ResourcesManager.LoadAudioClip(url);

                audio_source.clip = clip;
                audio_source.loop = is_loop;
                audio_source.playOnAwake = true;
                audio_source.spatialBlend = 1.0f; // 3D音效

                effects.Add(url, audio_source);
            }
            audio_source.mute = is_effect_mute;
            audio_source.enabled = true;
            audio_source.Play();
        }

        /// <summary>
        /// 解暂停
        /// </summary>
        /// <param name="url"></param>
        public void UnPauseEffect(string url)
        {
            AudioSource audio_source = null;
            if (!effects.ContainsKey(url))//判断是否已经在背景音乐表里面了
            {
                return;//没有这个背景音乐就直接返回
            }
            audio_source = effects[url];//有就把audio_source直接赋值过去
            audio_source.UnPause();//解暂停播放
        }

        /// <summary>
        /// 暂停声音
        /// </summary>
        /// <param name="url"></param>
        public void PauseEffect(string url)
        {
            AudioSource audio_source = null;
            if (!effects.ContainsKey(url))//判断是否已经在背景音乐表里面了
            {
                return;//没有这个背景音乐就直接返回
            }
            audio_source = effects[url];//有就把audio_source直接赋值过去
            audio_source.Pause();//暂停播放
        }


        /// <summary>
        /// 优化策略接口
        /// </summary>
        public static void Disable_over_audio()
        {
            //遍历背景音乐表
            foreach (AudioSource s in musics.Values)
            {
                if (!s.isPlaying)//判断是否在播放
                {
                    s.enabled = false;//不在播放就直接隐藏
                }
            }

            //遍历音效表
            foreach (AudioSource s in effects.Values)
            {
                if (!s.isPlaying)//判断是否在播放
                {
                    s.enabled = false;//不在播放就直接隐藏
                }
            }
        }
    }   
}
```

监测soundManager的声道SoundScan.cs 的code

```c#
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Tripeaks.Core
{
    public class SoundScan : MonoBehaviour
    {
        // Use this for initialization
        void Start()
        {
            //固定一个节奏去扫描，每隔0.5s扫描一次
            this.InvokeRepeating("Scan", 0, 0.5f);
        }
            //定时器函数
        void Scan()
        {
            SoundManager.Disable_over_audio();//调用隐藏AudioSource组件接口
        }
    }
}
```
