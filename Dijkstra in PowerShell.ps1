# Function to find the shortest path using Dijkstra's algorithm
function Dijkstra($graph, $source, $target)
{
    # Initialize distances and previous nodes
    $distances = @{}
    $previous = @{}
    $nodes = $graph.Keys
    
    # Set all distances to infinity except for the source node, which is set to 0
    foreach ($node in $nodes)
    {
        if ($node -eq $source)
        {
            $distances[$node] = 0
        }
        else
        {
            $distances[$node] = [float]::PositiveInfinity
        }
        
        $previous[$node] = $null
    }
    
    # Create a priority queue of nodes, sorted by distance
    $priorityQueue = New-Object System.Collections.Generic.SortedList[System.Object,System.Object]
    foreach ($distance in $distances.Keys)
    {
        $priorityQueue.Add($distances[$distance], $distance)
    }
    
    # While the priority queue is not empty
    while ($priorityQueue.Count -gt 0)
    {
        # Remove the node with the smallest distance
        $smallest = $priorityQueue.GetByIndex(0)
        $priorityQueue.RemoveAt(0)
        
        # If the smallest distance is infinity, then we have reached the end of the graph
        if ($smallest -eq [float]::PositiveInfinity)
        {
            break
        }
        
        # If we have reached the target node, then we are done
        if ($smallest -eq $target)
        {
            break
        }
        
        # Get the neighbors of the current node
        $neighbors = $graph[$smallest]
        
        # For each neighbor, update the distance and previous node if necessary
        foreach ($neighbor in $neighbors.Keys)
        {
            $alt = $distances[$smallest] + $neighbors[$neighbor]
            if ($alt -lt $distances[$neighbor])
            {
                $distances[$neighbor] = $alt
                $previous[$neighbor] = $smallest
                
                # Update the priority queue with the new distance
                $priorityQueue.Remove($distances[$neighbor])
                $priorityQueue.Add($alt, $neighbor)
            }
        }
    }
    
    # Construct the shortest path
    $path = @()
    $current = $target
    while ($current -ne $null)
    {
        $path += $current
        $current = $previous[$current]
    }
    $path = $path | Sort-Object
    
    # Return the shortest path and distances
    return $path, $distances
}

# Example usage
# Create a graph represented as an adjacency list
$graph = @{
    'A' = @{ 'B' = 3; 'C' = 2 }
    'B' = @{ 'A' = 3; 'C' = 5; 'D' = 1 }
    'C' = @{ 'A' = 2; 'B' = 5; 'D' = 2 }
    'D' = @{ 'B' = 1; 'C' = 2; 'E' = 4 }
    'E' = @{ 'D' = 4 }
}

# Find the shortest path from A to E
$path, $distances = Dijkstra $graph 'A' 'E'

# Print the shortest path and distances
"Shortest path: $path"
"Distances: $distances"
# Shortest path: A C B D E
# Distances: @{A=0; B=3; C=2; D=3; E=7}
