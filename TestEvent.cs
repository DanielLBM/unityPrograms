using System;

class program
{
    //写一个委托数学运算方法

    //定义一个委托

    public delegate int  MathOpearation(int x,int y);

    // 绑定委托

    MathOpearation add = Add;
    MathOpearation subtract = Subtract;

    main()
    {
        int a = 3;
        int b = 5;

        add(a,b);
        subtract(a,b);
        MathOpearation mulply = (x,y) => x*y;
        Console.Write("乘法运算:"+mulply(3,2));
    }


    //定义加法运算
    public void Add(int a, int b)
    {
        return a + b;
    }

    //定义加法运算
    public void Subtract(int a, int b)
    {
        return a - b;
    }

    
}