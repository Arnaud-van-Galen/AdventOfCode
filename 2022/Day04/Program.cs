using System;
using System.Linq;

namespace AOC202204
{
    internal class Program
    {
        static void Main(string[] args)
        {
            double[] SpeedTest = new double[1000];
            for (int i = 0; i < SpeedTest.Length; i++)
            {
                // Move the Data-fetching before or after the starting of the stopwatch (Alt + Arrow Up/Down)
                string[] Data = System.IO.File.ReadAllLines(@"C:\Users\ArnaudvanGalen\Repos\AdventOfCode\AdventOfCode\2022\Day04\Data.txt");
                System.Diagnostics.Stopwatch stopwatch = System.Diagnostics.Stopwatch.StartNew();
                int result = Part1(Data); // Change to Part1 or Part2
                SpeedTest[i] = stopwatch.Elapsed.TotalMilliseconds;
                Console.WriteLine(result);
                // Move the Data-output before or after the reading of the stopwatch (Alt + Arrow Up/Down)
            }
            Console.WriteLine(SpeedTest.Average());
        }

        static int Part1(string[] Data)
        {
            int OverlappingSum = 0;
            foreach (string AssignmentPair in Data)
            {
                string[] Areas = AssignmentPair.Split("-,".ToCharArray());
                int min1 = Convert.ToInt16(Areas[0]);
                int max1 = Convert.ToInt16(Areas[1]);
                int min2 = Convert.ToInt16(Areas[2]);
                int max2 = Convert.ToInt16(Areas[3]);
                if ((min1 <= min2 && max1 >= max2) || (min2 <= min1 && max2 >= max1)) // Smart code by Arnaud
                // if ((min1 - min2) * (max1 - max2) <= 0) // Even smarter code by Aki. Multiplications are only > 0 if both factors are positive or negative
                {
                    OverlappingSum++;
                }
            }
            return OverlappingSum;
        }
        static int Part2(string[] Data)
        {
            int OverlappingSum = 0;
            foreach (string AssignmentPair in Data)
            {
                string[] Areas = AssignmentPair.Split("-,".ToCharArray());
                int min1 = Convert.ToInt16(Areas[0]);
                int max1 = Convert.ToInt16(Areas[1]);
                int min2 = Convert.ToInt16(Areas[2]);
                int max2 = Convert.ToInt16(Areas[3]);
                if (!(max1 < min2 || max2 < min1))
                {
                    OverlappingSum++;
                }
            }
            return OverlappingSum;
        }
    }
}