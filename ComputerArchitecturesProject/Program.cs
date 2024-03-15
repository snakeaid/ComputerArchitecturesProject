var lines = ReadLines();

string[] ReadLines()
{
    var lines = new List<string>();
    
    while (true)
    {
        var line = Console.ReadLine();
        if(line == string.Empty)
            break;
        
        lines.Add(line);
    }

    return lines.ToArray();
}