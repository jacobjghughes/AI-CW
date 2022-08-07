- 5: consideration of the strengths and shortcomings of the approaches used so far in Parts 1, 2, and 3.
  - discussion of the extent to which the kind of algorithms developed during Parts 1, 2, and 3, may or may not generalise successfully to real-world search problems
- 10: consideration of the relevance and rationale for a selection of additional AI approaches that you present
  - arguments for and against the adoption of selected AI techniques for dealing with real-world versions of the types of problems considered in Parts 1, 2, and 3 are clear, compelling and creative
- 5: consideration of the design and detail of these approaches
  -  these marks are awarded to the extent that the description and discussion of AI techniques is technically sound and demonstrates a good grasp of the way that they work
- 5: good writing and presentation
  - writing is clear, concise, and articulate, the report is well structured and free from padding and any diagrams, pseudocode, etc., are
    informative and well presented

*A dynamic version of the problem where obstacles, charging stations and/or oracle can move about randomly (or deliberately flee from an agent)*

## Part One: Breadth-First Search shortest path finder

The goal of Part One was to have an agent efficiently achieve a task of the form `go(?Pos)` or `find(?Obj)`, by minimizing the number of moves made and runtime. I achieved this by implementing a breadth-first search (BFS) algorithm. The benefits of using a BFS is that it is complete, meaning that if a solution exists (for example a route to a cell on the board when the task is `go(p(X,Y)))`) then the BFS algorithm will find it. Additionally, the BFS algorithm always finds the shortest possible solution, which is ideal when the primary objective is minimizing moves made. The runtime of the BFS algorithm is minimized by adapting it into an A* algorithm, by assigning a score to each cell comprised of its Manhattan distance from the target and its distance from the root node. By prioritising lowest scoring cells when expanding the search, the first complete solution found is guaranteed to also be the shortest solution, and further recursion of the algorithm is not required, thus reducing the overall runtime of the algorithm. The BFS algorithm also stores a list of `Visited` nodes, which can be subsequently ignored if they are selected due to being adjacent to a different node. Because each cell can have up to 4 adjacent cells, storing Visited cells can mitigate a large amount of unnecessary duplicate checks, at the expense of requiring a vacant amount of memory to store a list of visited nodes (theoretically up to n^2^ nodes would be stored in an n x n grid).

When performing a `find(?Obj)` task, a standard BFS is used because the location of Object being searched for is unknown. Searching for unknown nodes has a large impact on runtime - searching for a specific Object in an n x n grid has a time complexity of O(n^2^). In part one, the impact on runtime that use of the `find` task had was not massive, because the grids are relatively small at 20 x 20, and typically finished execution when the first instance of an object was found. 

In a worst-case scenario, where the BFS algorithm is being implemented to search for a specific object in a much larger grid, the impact on runtime would have polynomial growth, scaling with grid size. In this instance, a potential adaption to the algorithm could be to perform an initial BFS on the entire grid and storing a list of locations and ID's of found objects in memory. Because the location of the `find` target is now known, a Manhattan distance heuristic for the scoring function could be calculated to use an A* search algorithm. While the initial full grid search will be time intensive, you could make that time back because subsequent searches are now optimal. The implementation of this method would have varying impact on total runtime and viability, and it would be best suited to a situation with a very large grid size, when objects are sparse or specific, and there are no memory limitations.

## Part Two: Complex route planning

## Part Three: Multi-agent maze solver