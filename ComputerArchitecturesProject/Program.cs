using ComputerArchitecturesProject;

var lines = ReadLines();
var averages = GetAveragesForKeys(lines);

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

KeyValue[] GetAveragesForKeys(string[] lines)
{
    var keyValues = lines.Select(ParseKeyValueFromLine);
    var keyGroups = keyValues.GroupBy(keyValue => keyValue.Key);
    var keyAverages = keyGroups.Select(GetAverageForKey);

    return keyAverages.ToArray();
}

KeyValue GetAverageForKey(IGrouping<string, KeyValue> keyGroup)
{
    var average = keyGroup.Sum(keyValue => keyValue.Value) / keyGroup.Count();

    return new KeyValue { Key = keyGroup.Key, Value = average };
}

KeyValue ParseKeyValueFromLine(string line)
{
    var lineParts = line.Split(" ");
    var key = lineParts[0];
    var value = int.Parse(lineParts[1]);

    return new KeyValue { Key = key, Value = value };
}
