#### ��ȷ������Unity��Դ����ĺô���

1. ��Ч�Ĺ�����Դ
2. ����ķ����ڴ�(���ⲻ��Ҫ���ڴ濪�� �� ����ͬһ��Asset����������AssetBundle�Ȼ��ֱ���Ϸ����)
3. ������������(�������ظ���������Ϸ����ͨ��Patch����ʽ��̬���²�����Ϸ����)

4. �����ټ������ķ�ʽ���ٳ����С(����������Դһ���Դ���Ϸ������)

5. �������ٿ���(��̬�;�̬����Դ��ʽ�������ã���Ч����)


���Կ���Resources�µ���Դ�ļ���û�б������ͼ���������Ϊ������Texture2D��Դ���ڡ�
ͬʱû�з�����ResourcesĿ¼�µ���Դ�����û�б���Ϸʹ�ã������ǲ��ᱻ�������Ϸ��(��֮����ResourcesĿ¼�¼�ʹδ��ʹ��Ҳ�ᱻ�������Ϸ��)��


��Unity���������ᵽ������Ӧ�þ���ȥ����ʹ��Resources��
ԭ�����£�

1. 
   Use of the Resources folder makes fine-grained memory management more difficult.(ʹ��Resources folder��ʹ�ڴ���������)

2. Improper use of Resources folders will increase application startup time and the length of builds.(�������ʹ��Resources folders��ʹ���������ͱ���ʱ��䳤)

3. As the number of Resources folders increases, management of the Assets within those folders becomes very difficult.(����Resources folders���������ӣ�Assets����Խ��Խ����)

4. The Resources system degrades a project��s ability to deliver custom content to specific platforms and eliminates the possibility of incremental content upgrades.(Resources System��������Ŀ���ڸ�ƽ̨����Դ�Ķ�̬������������ΪResourcesĿ¼�µ���Դ������ζ��ᱻ�������Ϸ������)
   AssetBundle Variants are Unity��s primary tool for adjusting content on a per-device basis.(AssetBundle��Unity����豸��̬���µ���Ҫ����)



#### ̸̸Unity����Դ����

- ��Unity���ʵ����ȷָ��, Ҫʹ��AssetBundle������ResourcesĿ¼��������Դ��Ȼ�������鲢����Unity�ٷ���������ô���á���Ϊʹ��AssetBundle���������޷�ʵ��һ����Ч���õģ���ȫ�Զ�����Դ��������

- ��Unity�ٷ�˵��һ�������ַ�����

  ����һ����������Ϸ�ǹؿ����ʵģ�������һ���ؿ����������AssetBundle��Ȼ���ڽ�����һ�ؿ�ʱ��ж�ر��ؿ��м��ص�����AssetBundle. �����ֻ����ƺ�ֻ�Է�ŭ��С������С��Ϸ�����ð�:D��

  ����������������Ϸ���ǹؿ���ģ���ôUnity�Ƽ���һ����Դ��AssetBundle���ü�����

- ���һ������Asset������AssetBundle)���ô�AssetBundle�������ü�����1. �����AssetBundle�״μ��أ�������ǰ���ü���Ϊ0), ����Ҫ�ݹ�����������ü�����1��

- ���һ��AssetBundle�����ü���Ϊ0���ͷ����AssetBundle��ͬʱ����Ҫ�ݹ�����������ü�����1

- ���ǣ����������ŭС��һ����ͨ����Ϸ����Ȼ�ƺ�ֻ�з������������á����ҷ�����էһ�����걸�ģ���Ϊ������GC�㷨��һ��ʵ�֡�


https://blog.gotocoding.com/archives/1262