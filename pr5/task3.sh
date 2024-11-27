Код Java

package ru.qq;

public class Main {
    public static void main(String[] args) {
        foo(10);
    }

    private static int foo(int x){
        int result = (x * 10) + 42;
        return result;
    }
}


Код C#

using System;

namespace Ru.Qq
{
    class Program
    {
        static void Main(string[] args)
        {
            int result = Foo(10);
            Console.WriteLine(result);
        }

        private static int Foo(int x)
        {
            int result = (x * 10) + 42;
            return result;
        }
    }
}
