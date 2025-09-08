#import "template.typ": *

#show: project.with(
  title: "Network Routing",
  authors: (
    "Gage Moore",
  ),
  date: "October 19, 2023",
)


= Introduction
Dijkstra's algorithm is an algorithm for finding the shortest path between nodes in a graph. It has many useful applications, from navigation systems to robotics. In this report, the algorithm will be explained and analyzed in terms of $V$, the vertices of the graph, and $E$, the edges of the graph.

= Priority Queue Implementations
Dijkstra's algorithm is commonly implemented with a priority queue. For this lab, two different priority queues were tested–an unsorted array and a binary heap.

The algorithm uses the priority queue to track distances to each vertex. The queue must have a `delete_min()` operation which returns the vertex with the minimum distance and removes it, a `decrease_key()` operation which sets a vertex's distance to a lower value, and an `insert()` key which adds a new vertex to the queue.

Both queue implementations in this algorithm use a vertex class in order to easily match node id's, (which correspond to the actual id in the graph), with the overall distance from source node. The unsorted array and binary heap both have a list of vertex objects that are structured like so:

```py
class Vertex:
    def __init__(self, node_id, distance):
        self.node_id = node_id
        self.distance = distance
```

== Unsorted Array
The simplest implementation of a priority queue is a simple unsorted array of elements. Our array is a one-dimensional list of distances where the index of each distance is the corresponding vertex index. A lookup list keeps track of the index of specific nodes as they change when elements are deleted.

```py
class Array():
    '''
    Initialize the array.
    Time Complexity: O(1)
    Space Complexity: O(1)
    '''
    def __init__(self):
        self.nodes = []
        self.lookup = []

    '''
    Return the size of the array.
    Time Complexity: O(1)
    Space Complexity: O(1)
    '''
    def size(self):
        return len(self.nodes)
    
    '''
    Insert a node into the array.
    Time complexity: O(1)
    Space complexity: O(1)
    '''
    def insert(self, index, distance):
        self.nodes.append(Vertex(index, distance))
        self.lookup.append(len(self.nodes)-1)

    '''
    Return the index of the node with the minimum distance and delete it.
    Time complexity: O(|V|)
    Space complexity: O(1)
    '''
    def delete_min(self):
        min_index = 0
        # iterate through nodes to find one with smallest distance
        for i in range(len(self.nodes)): # O(|V|)
            if self.nodes[i].distance < self.nodes[min_index].distance:
                min_index = i
        min = self.nodes[min_index].node_id
        del self.nodes[min_index]

        for i in range(min+1, len(self.lookup)):
            self.lookup[i] -= 1

        return min

    '''
    Update the distance of the node at given index.
    Time complexity: O(1)
    Space complexity: O(1)
    '''
    def decrease_key(self, index, distance):
        self.nodes[self.lookup[index]].distance = distance
```

*Insert Operation*
In the unsorted array, the insert function `insert()` runs in $O(1)$ time and has a space complexity of $O(1)$ since it simply appends a new vertex object to the nodes list and updates the lookup list with that vertex's index.

*Delete Min Operation*
This operation is contained within the `delete_min()` function. It iterates over every vertex contained in the array in order to locate the smallest distance and return the associated index. As such, the time complexity is $O(|V|)$ while the space compelxity is only $O(1)$ since no space is dynamically allocated.

*Decrease Key Operation*
The function `decrease_key()` simply sets a distance in the array to a given value. Since all it does is access the list, it runs in $O(1)$ time and has a space complexity of $O(1)$.

== Binary Heap
The binary heap implementation of a priority queue is more fit for larger datasets. The binary heap grows row by row from left to right and is constrained by the fact that the value in one row is smaller than any of the values of the row below it. This implementation, similar to the array, maintains a list of vertex objects in order to match node id's with distances, and a list of lookup values from node id to list index.

\
```py
class Heap():
    '''
    Initialize the heap.
    Time Complexity: O(1)
    Space Complexity: O(1)
    '''
    def __init__(self):
        self.nodes = []
        self.lookup = []

    '''
    Return the size of the heap.
    Time Complexity: O(1)
    Space Complexity: O(1)
    '''
    def size(self):
        return len(self.nodes)
    
    '''
    Insert a node into the heap.
    Time complexity: O(log|V|)
    Space complexity: O(1)
    '''
    def insert(self, index, distance):
        self.nodes.append(Vertex(index, distance))
        self.lookup.append(len(self.nodes)-1)
        self.bubble_up(len(self.nodes)-1) # O(log|V|)
    
    '''
    Return the index of the node with the minimum distance and delete it.
    Time complexity: O(log|V|)
    Space complexity: O(1)
    '''
    def delete_min(self):
        min = self.nodes[0].node_id  
        self.nodes[0] = self.nodes[len(self.nodes)-1]
        self.nodes.pop()
        self.bubble_down(0) # O(log|V|)
        return min
    
    '''
    Update the distance of the node at given index.
    Time complexity: O(log|V|)
    Space complexity: O(1)
    '''
    def decrease_key(self, index, distance):
        if self.lookup[index] > len(self.nodes)-1:
            return
        self.nodes[self.lookup[index]].distance = distance
        self.bubble_up(self.lookup[index]) # O(log|V|)

    '''
    Sift the node at given index up the heap until it is above all nodes
    with a greater distance.
    Time complexity: O(log|V|)
    Space complexity: O(1)
    '''
    def bubble_up(self, index):
        parent = (index-1) // 2

        if self.nodes[parent].distance > self.nodes[index].distance:
            self.swap(index, parent) # O(1)
            self.bubble_up(parent) # O(log|V|)

    '''
    Sift the node at given index down the heap until it is below all nodes
    with a lesser distance.
    Time complexity: O(log|V|)
    Space complexity: O(1)
    '''
    def bubble_down(self, index):
        left_child = (index * 2) + 1
        right_child = (index * 2) + 2

        # determine which side to sift down
        if left_child > len(self.nodes)-1 or right_child > len(self.nodes)-1:
            min_child =  -1
        elif (self.nodes[left_child].distance < self.nodes[right_child].distance):
            min_child = left_child
        else:
            min_child = right_child
        
        # exit condition for recursion (node is leaf)
        if min_child < 1 or min_child > len(self.nodes)-1:
            return
        
        if self.nodes[index].distance > self.nodes[min_child].distance:
            self.swap(index, min_child) # O(1)
            self.bubble_down(min_child) # O(log|V|)

    '''
    Swap the nodes at the given indices.
    Time complexity: O(1)
    Space complexity: O(1)
    '''
    def swap(self, i, j):
        temp = self.nodes[i]
        self.nodes[i] = self.nodes[j]
        self.nodes[j] = temp
        self.lookup[self.nodes[i].node_id] = i
        self.lookup[self.nodes[j].node_id] = j
```

*Insert Operation*
The insert operation is handled in the `insert()` function. Because every insertion calls the `bubble_up()` function, insertions are unavoidably $O(log |V|)$. This is because the `bubble_up()` function compares the vertex with the value of the parent with each loop, and since the heap is a binary tree, this splits the number of vertices to compare against in half with each loop. The space complexity is only $O(1)$, since a single element is appended to the lists each function call.

*Delete Min Operation*
The smallest value in the heap will simply be the first one, so it is able to return the index of the first vertex in constant time. It still has to set the distance to infinity and let the vertex bubble down through the heap, which runs in $O(log |V|)$ time. This is because the `bubble_down()` function swaps the vertex that is sifting down with each new row in the heap, a comparison that splits the length of remaining vertices to compare against in half with each loop.

The space complexity is $O(1)$ since the actual space used does not change.

*Decrease Key Operation*
This operation is implemented in the `decrease_key()` function. It changes the distance to a vertex and allows it to bubble up through the heap. The function runs ins $O(log |V|)$ time due to the `bubble_up()` function. The `bubble_up()` function, as mentioned earlier, runs recursively splitting the number of nodes to consider in half with each call.

The space complexity is $O(1)$ since the actual space used does not change.

= Time and Space Complexity
In addition to the functions of the priority queue classes discussed above, the following functions of the actual network solver have the following complexities.

== Dijkstra's Algorithm
The actual algorithm for computing the shortest path of the graph is implemented using Dijkstra's algorithm, which, using a list of node distances and previously visited nodes, loops through each node, finding the closest nodes and updating distances to that node's neighbors.

```py
def dijkstra(self, use_heap):
    self.distances = []
    self.previous = []

    # setup arrays for algorithm, O(1)
    self.distances = [float('inf')]*len(self.network.nodes)
    self.previous = [None]*len(self.network.nodes)
    self.distances[self.source] = 0

    # initialize priority queue, O(1)
    if use_heap:
        H = Heap()
    else:
        H = Array()

    for i in range(len(self.network.nodes)): # O(|V|)
        H.insert(i, self.distances[i]) # O(1) or O(log|V|), array or heap respectively

    while H.size() > 0: # O(|V|)
        u = H.delete_min() # O(|V|) or O(log|V|), array or heap respectively

        E = self.network.nodes[u].neighbors
        for i in range(len(E)): # O(|E|)
            v = E[i].dest.node_id

            if self.distances[u] + E[i].length < self.distances[v]:
                self.distances[v] = self.distances[u] + E[i].length
                self.previous[v] = E[i]
                H.decrease_key(v, self.distances[v]) # O(1) or O(log|V|), array or heap respectively
```

The function sets up the lists by setting the distance to every node to infinity and the distance to the source as 0, which takes constant time. It then initalizes the priority queue, either an unsorted array or binary heap and inserts each node. It loops until the priority queue is empty, (all nodes have been visited), calling the `delete_min()` for each node and `decrease_key()` for each neighbor of that node.

Because the specific time complexities differ in an unsorted array versus a binary heap, the time complexity of this function differs depending on the data structure used. When an array is used, it runs in $O(|V|^2 + |E|)$ time, because `delete_min()`, which iterates through every node in its worst case, will be called for every iteration of the algorithm.

When a heap is used, the time complexity is $O((|V|+|E|) log|V|)$, since the function will run a $O(log|V|)$ operation for every vertex and a $O(log|V|)$ operation for every edge.

= Examples

#table(
  columns: (auto),
  inset: 0pt,
  align: horizon,
  stroke: none,
  [#image("Screen Shot 2023-10-15 at 8.14.58 PM.png", fit: "contain", height: 45%)],
  [#image("Screen Shot 2023-10-15 at 8.15.18 PM.png", fit: "contain", height: 45%)],
  [#image("Screen Shot 2023-10-15 at 8.15.34 PM.png", fit: "contain", height: 45%)]
)
= Runtime Analysis
In order to evaluate my algorithm, I ran it using both an array and a heap for graph sizes of $n$ where $n in {100, 1000, 10000, 100000, 1000000}$. The table below shows the results of these experiments.
#table(
  columns: (auto, auto, auto),
  inset: 10pt,
  align: horizon,
  fill: (col, row) => if col == 1 and row == 5 { rgb("#ffffcc") } else { white },
  [*Size*], [*Array Runtimes (s)*], [*Heap Runtimes (s)*],
  [100], [0.000641,\ 0.001233,\ 0.000616,\ 0.001193,\ 0.000634\ *Mean: 0.000863*], [0.000871,\ 0.001342,\ 0.001428,\ 0.001676,\ 0.001641\ *Mean: 0.001392*],
  [1,000], [0.046540,\ 0.118861,\ 0.111799,\ 0.129244,\ 0.092185\ *Mean: 0.099726*], [0.011872,\ 0.020800,\ 0.036809,\  0.013864,\ 0.020766\ *Mean: 0.020822*],
  [10,000], [8.252042,\ 9.324537,\ 8.704111,\ 11.34207,\ 8.394428\ *Mean: 9.203438*], [0.307296,\ 0.351058,\ 0.337391,\ 0.437984,\ 0.281401\ *Mean: 0.343026*],
  [100,000], [1167.818934,\ 1101.651630,\ 1129.197670,\ 1253.530700,\ 1098.115702\ *Mean: 1150.062947*], [4.733895,\ 4.388978,\ 4.750049,\ 5.333665,\ 4.378361\ *Mean: 4.716990*],
  [1,000,000], [654907377690,\ 493154003700,\ 593501858189,\ 602728130390,\ 504182854663\ *Mean: 569694844926.4*], [62.005953,\ 77.276958,\ 71.366169,\ 74.020044,\ 69.872106\ *Mean: 70.908246*]  
)
| NOTE: highlighted cells are estimated, not observed.

When graphing the means for the two data structures, the sheer increase in runtime when using an array becomes apparent.

#image("output.png", height: 35%)
#image("output2.png", height:35%)

The differences between the two data structures is less pronounced for smaller graph sizes, but as graph sizes increases, the running time with an array increases significantly faster than it does with a heap. The chart below helps to visualize this by plotting the first three graph sizes for both data structures.

#image("output3.png", height: 35%)

The reason that a binary heap is more equipped for larger data sets is because it does not need to iterate through every single element in order to find the minimum value whereas an unsorted array does. The heap maintains smallest values at the top, and bubbling up and down to account for insertions and deletions works in $O(log |V|)$ time since the tree splits in half with each branch.

As made evident by the table of data included above, there are some cases for smaller sizes of $n$ when the heap actually takes longer than an array. This is due to the fact that a heap involves extra overhead in order to keep the elements in order. The unsorted array can access elements in quick $O(1)$ operations while the heap will always involve $O(log |V|)$. The advantage of the heap becomes apparent for larger graph sizes when the array is ill-equipped to iterate through every single node to find minimum values.

= Source Code
The full program for Dijkstra's algorithm with the two implementations of a priority queue is included below.

```py
#!/usr/bin/python3


from CS312Graph import *
import time

class Vertex:
    '''
    Create a Vertex object. Used to represent a node in the queues.
    Time Complexity: O(1)
    Space Complexity: O(1)
    '''
    def __init__(self, node_id, distance):
        self.node_id = node_id
        self.distance = distance

class Array():
    '''
    Initialize the array.
    Time Complexity: O(1)
    Space Complexity: O(1)
    '''
    def __init__(self):
        self.nodes = []
        self.lookup = []

    '''
    Return the size of the array.
    Time Complexity: O(1)
    Space Complexity: O(1)
    '''
    def size(self):
        return len(self.nodes)
    
    '''
    Insert a node into the array.
    Time complexity: O(1)
    Space complexity: O(1)
    '''
    def insert(self, index, distance):
        self.nodes.append(Vertex(index, distance))
        self.lookup.append(len(self.nodes)-1)

    '''
    Return the index of the node with the minimum distance and delete it.
    Time complexity: O(|V|)
    Space complexity: O(1)
    '''
    def delete_min(self):
        min_index = 0
        # iterate through nodes to find one with smallest distance
        for i in range(len(self.nodes)): # O(|V|)
            if self.nodes[i].distance < self.nodes[min_index].distance:
                min_index = i
        min = self.nodes[min_index].node_id
        del self.nodes[min_index]

        for i in range(min+1, len(self.lookup)):
            self.lookup[i] -= 1

        return min

    '''
    Update the distance of the node at given index.
    Time complexity: O(1)
    Space complexity: O(1)
    '''
    def decrease_key(self, index, distance):
        self.nodes[self.lookup[index]].distance = distance

class Heap():
    '''
    Initialize the heap.
    Time Complexity: O(1)
    Space Complexity: O(1)
    '''
    def __init__(self):
        self.nodes = []
        self.lookup = []

    '''
    Return the size of the heap.
    Time Complexity: O(1)
    Space Complexity: O(1)
    '''
    def size(self):
        return len(self.nodes)
    
    '''
    Insert a node into the heap.
    Time complexity: O(log|V|)
    Space complexity: O(1)
    '''
    def insert(self, index, distance):
        self.nodes.append(Vertex(index, distance))
        self.lookup.append(len(self.nodes)-1)
        self.bubble_up(len(self.nodes)-1) # O(log|V|)
    
    '''
    Return the index of the node with the minimum distance and delete it.
    Time complexity: O(log|V|)
    Space complexity: O(1)
    '''
    def delete_min(self):
        min = self.nodes[0].node_id  
        self.nodes[0] = self.nodes[len(self.nodes)-1]
        self.nodes.pop()
        self.bubble_down(0) # O(log|V|)
        return min
    
    '''
    Update the distance of the node at given index.
    Time complexity: O(log|V|)
    Space complexity: O(1)
    '''
    def decrease_key(self, index, distance):
        if self.lookup[index] > len(self.nodes)-1:
            return
        self.nodes[self.lookup[index]].distance = distance
        self.bubble_up(self.lookup[index]) # O(log|V|)

    '''
    Sift the node at given index up the heap until it is above all nodes
    with a greater distance.
    Time complexity: O(log|V|)
    Space complexity: O(1)
    '''
    def bubble_up(self, index):
        parent = (index-1) // 2

        if self.nodes[parent].distance > self.nodes[index].distance:
            self.swap(index, parent) # O(1)
            self.bubble_up(parent) # O(log|V|)

    '''
    Sift the node at given index down the heap until it is below all nodes
    with a lesser distance.
    Time complexity: O(log|V|)
    Space complexity: O(1)
    '''
    def bubble_down(self, index):
        left_child = (index * 2) + 1
        right_child = (index * 2) + 2

        # determine which side to sift down
        if left_child > len(self.nodes)-1 or right_child > len(self.nodes)-1:
            min_child =  -1
        elif (self.nodes[left_child].distance < self.nodes[right_child].distance):
            min_child = left_child
        else:
            min_child = right_child
        
        # exit condition for recursion (node is leaf)
        if min_child < 1 or min_child > len(self.nodes)-1:
            return
        
        if self.nodes[index].distance > self.nodes[min_child].distance:
            self.swap(index, min_child) # O(1)
            self.bubble_down(min_child) # O(log|V|)

    '''
    Swap the nodes at the given indices.
    Time complexity: O(1)
    Space complexity: O(1)
    '''
    def swap(self, i, j):
        temp = self.nodes[i]
        self.nodes[i] = self.nodes[j]
        self.nodes[j] = temp
        self.lookup[self.nodes[i].node_id] = i
        self.lookup[self.nodes[j].node_id] = j

class NetworkRoutingSolver:
    def __init__(self):
        pass

    '''
    Time Complexity: O(1)
    Space Complexity: O(1)
    '''
    def initializeNetwork( self, network ):
        assert( type(network) == CS312Graph )
        self.network = network

    '''
    Run dijkstra's algorithm on the network using either an array or a heap.
    Time complexity with array: O(|V|^2 + |E|)
    Time complexity with heap: O(|V| + |E| log|V|)
    Space complexity: O(|V|)
    '''
    def dijkstra(self, use_heap):
        self.distances = []
        self.previous = []

        # setup arrays for algorithm, O(1)
        self.distances = [float('inf')]*len(self.network.nodes)
        self.previous = [None]*len(self.network.nodes)
        self.distances[self.source] = 0

        # initialize priority queue, O(1)
        if use_heap:
            H = Heap()
        else:
            H = Array()
 
        for i in range(len(self.network.nodes)): # O(|V|)
            H.insert(i, self.distances[i]) # O(1) or O(log|V|), array or heap respectively

        while H.size() > 0: # O(|V|)
            u = H.delete_min() # O(|V|) or O(log|V|), array or heap respectively

            E = self.network.nodes[u].neighbors
            for i in range(len(E)): # O(|E|)
                v = E[i].dest.node_id

                if self.distances[u] + E[i].length < self.distances[v]:
                    self.distances[v] = self.distances[u] + E[i].length
                    self.previous[v] = E[i]
                    H.decrease_key(v, self.distances[v]) # O(1) or O(log|V|), array or heap respectively

    '''
    Calculate the cost and path from the source to the destination.
    Time complexity: O(|V|)
    Space complexity: O(|V|)
    '''
    def getShortestPath( self, destIndex ):
        self.dest = destIndex
        solved_path = []

        edge = self.previous[self.dest]
        while edge:
            solved_path.append( (edge.src.loc, edge.dest.loc, '{:.0f}'.format(edge.length)) )
            edge = self.previous[edge.src.node_id]

        return {'cost':self.distances[self.dest], 'path':solved_path}

    '''
    Entry function for the solver.
    Time complexity with array: O(|V|^2)
    Time complexity with heap: O(|V| + |E| log|V|)
    Space complexity: O(|V|)
    '''
    def computeShortestPaths( self, srcIndex, use_heap=False ):
        self.source = srcIndex
        t1 = time.time()
        self.dijkstra(use_heap) # O(|V|^2) or O(|V| + |E| log|V|), array or heap respectively
        t2 = time.time()
        return (t2-t1)
    
```
