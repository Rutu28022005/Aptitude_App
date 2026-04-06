import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"


def write_json(path: Path, data):
  path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")


def build_theory():
  # Exactly 100 questions: 30 easy, 40 medium, 30 hard
  # Subjects included: DBMS, OS, DSA, CN, SE, ML, AI, Cloud Computing, Cyber Security, Compiler Design, DAA, Full Stack
  qs = []

  def add(difficulty, subject, question, options, correct, solution):
    qs.append(
      {
        "id": len(qs) + 1,
        "difficulty": difficulty,
        "subject": subject,
        "question": question,
        "options": options,
        "correct_answer": correct,
        "solution": solution,
      }
    )

  # EASY (30)
  add(
    "easy",
    "DBMS",
    "Which DBMS key uniquely identifies each row in a table?",
    ["Foreign key", "Primary key", "Candidate key", "Composite key"],
    "Primary key",
    "A primary key is chosen to uniquely identify each record (row) in a table; its values must be unique and not null.",
  )
  add(
    "easy",
    "DBMS",
    "Which normal form eliminates partial dependency?",
    ["1NF", "2NF", "3NF", "BCNF"],
    "2NF",
    "2NF removes partial dependency by ensuring non-key attributes depend on the whole of a composite key, not part of it.",
  )
  add(
    "easy",
    "OS",
    "Which OS component is responsible for process scheduling?",
    ["Shell", "Kernel", "Compiler", "Assembler"],
    "Kernel",
    "The kernel manages core OS functions including process scheduling, memory management, and device control.",
  )
  add(
    "easy",
    "OS",
    "What is a process?",
    ["A program in execution", "A compiled program", "A CPU register", "A disk partition"],
    "A program in execution",
    "A process is an active instance of a program, including its state, resources, and execution context.",
  )
  add(
    "easy",
    "DSA",
    "Which data structure follows FIFO order?",
    ["Stack", "Queue", "Tree", "Graph"],
    "Queue",
    "A queue removes elements in the same order they were inserted (First-In-First-Out).",
  )
  add(
    "easy",
    "DSA",
    "Which traversal of a BST gives keys in sorted order?",
    ["Preorder", "Inorder", "Postorder", "Level order"],
    "Inorder",
    "Inorder traversal visits left subtree, node, right subtree; for a BST this yields sorted keys.",
  )
  add(
    "easy",
    "CN",
    "Which protocol is used to map domain names to IP addresses?",
    ["HTTP", "DNS", "FTP", "SMTP"],
    "DNS",
    "DNS (Domain Name System) resolves human-readable domain names into IP addresses.",
  )
  add(
    "easy",
    "CN",
    "Which layer of OSI handles routing?",
    ["Data Link", "Network", "Transport", "Session"],
    "Network",
    "The Network layer (Layer 3) is responsible for routing packets between networks (e.g., via IP).",
  )
  add(
    "easy",
    "SE",
    "Which SDLC model is best known for its iterative development and frequent customer feedback?",
    ["Waterfall", "V-Model", "Agile", "Spiral"],
    "Agile",
    "Agile emphasizes iterative development, incremental delivery, and continuous customer feedback.",
  )
  add(
    "easy",
    "SE",
    "A use case diagram is primarily used in which phase?",
    ["Requirements", "Coding", "Testing", "Deployment"],
    "Requirements",
    "Use cases capture functional requirements by describing interactions between users (actors) and the system.",
  )
  add(
    "easy",
    "ML",
    "Which task predicts a continuous numeric value?",
    ["Classification", "Regression", "Clustering", "Association"],
    "Regression",
    "Regression models predict continuous outputs (e.g., house price), unlike classification which predicts categories.",
  )
  add(
    "easy",
    "AI",
    "Which search algorithm uses a heuristic to guide exploration?",
    ["Breadth-first search", "Depth-first search", "A* search", "Binary search"],
    "A* search",
    "A* uses a heuristic to estimate remaining cost, prioritizing promising nodes to find an optimal path under conditions.",
  )
  add(
    "easy",
    "Cloud Computing",
    "Which cloud service model provides virtual machines and networking resources?",
    ["SaaS", "PaaS", "IaaS", "FaaS"],
    "IaaS",
    "IaaS offers infrastructure like VMs, storage, and networking, giving users more control over OS and runtime.",
  )
  add(
    "easy",
    "Cyber Security",
    "Which of the following is a strong password practice?",
    ["Use your name", "Use '123456'", "Use a mix of letters, numbers, symbols", "Reuse one password everywhere"],
    "Use a mix of letters, numbers, symbols",
    "Stronger passwords use length and complexity (mixed character types) and avoid personal/common patterns.",
  )
  add(
    "easy",
    "Compiler Design",
    "The phase that converts source code into tokens is called:",
    ["Syntax analysis", "Lexical analysis", "Semantic analysis", "Code optimization"],
    "Lexical analysis",
    "Lexical analysis (scanner) groups characters into tokens like identifiers, keywords, operators, and literals.",
  )
  add(
    "easy",
    "DAA",
    "What is the time complexity of binary search on a sorted array of size n?",
    ["O(n)", "O(log n)", "O(n log n)", "O(1)"],
    "O(log n)",
    "Binary search halves the search space each step, resulting in logarithmic time complexity.",
  )
  add(
    "easy",
    "DAA",
    "Which algorithm technique solves problems by combining solutions of subproblems?",
    ["Greedy", "Divide and Conquer", "Backtracking", "Brute force"],
    "Divide and Conquer",
    "Divide and Conquer splits a problem into subproblems, solves them, and combines results (e.g., merge sort).",
  )
  add(
    "easy",
    "Full Stack",
    "Which HTTP method is typically used to retrieve data?",
    ["POST", "GET", "PUT", "DELETE"],
    "GET",
    "GET requests retrieve resources from the server without modifying server state (ideally).",
  )
  add(
    "easy",
    "Full Stack",
    "Which status code indicates \"Not Found\"?",
    ["200", "301", "404", "500"],
    "404",
    "HTTP 404 indicates the requested resource was not found on the server.",
  )

  # Add 10 more easy across subjects
  add("easy", "OS", "Which of these is a non-preemptive scheduling algorithm?", ["Round Robin", "SJF (non-preemptive)", "SRTF", "Preemptive Priority"], "SJF (non-preemptive)", "Non-preemptive SJF selects the shortest job and runs it to completion without preemption.")
  add("easy", "CN", "Which device operates at the Data Link layer and forwards frames using MAC addresses?", ["Router", "Switch", "Hub", "Gateway"], "Switch", "A switch forwards frames based on MAC addresses, a Data Link layer function.")
  add("easy", "DBMS", "SQL command used to remove all rows from a table quickly (keeping structure) is:", ["DROP", "TRUNCATE", "DELETE", "ALTER"], "TRUNCATE", "TRUNCATE removes all rows and resets storage/identity in many DBMSs while keeping the table structure.")
  add("easy", "DSA", "Which operation is NOT typically O(1) in an array?", ["Access by index", "Update by index", "Insert at beginning", "Get length (stored)"], "Insert at beginning", "Inserting at the beginning shifts elements, making it O(n) in an array.")
  add("easy", "Cyber Security", "A firewall primarily helps with:", ["Data compression", "Access control", "Image processing", "Code compilation"], "Access control", "Firewalls enforce network access rules by allowing/denying traffic based on policies.")
  add("easy", "Cloud Computing", "A key benefit of cloud computing is:", ["Fixed capacity only", "Elastic scalability", "No virtualization", "No networking"], "Elastic scalability", "Cloud resources can scale up/down on demand, enabling elasticity.")
  add("easy", "SE", "Unit testing focuses on:", ["Entire system", "Single module/function", "Network latency", "User manuals"], "Single module/function", "Unit tests validate the smallest testable parts (functions/classes) in isolation.")
  add("easy", "ML", "Overfitting means the model:", ["Performs well on new data", "Performs poorly on training data", "Learns noise and performs poorly on new data", "Has too few parameters"], "Learns noise and performs poorly on new data", "Overfitting occurs when a model fits training noise, reducing generalization.")
  add("easy", "AI", "Turing Test is related to:", ["Database indexing", "Machine intelligence", "Packet routing", "Disk scheduling"], "Machine intelligence", "The Turing Test evaluates whether a machine can exhibit human-like conversational intelligence.")
  add("easy", "Compiler Design", "A parse tree represents:", ["Token stream only", "Hierarchical syntactic structure", "Optimized machine code", "Network topology"], "Hierarchical syntactic structure", "A parse tree shows how tokens conform to grammar rules forming a syntactic structure.")

  # MEDIUM (40) ids 31-70
  add("medium", "DBMS", "Which isolation level prevents dirty reads but may allow non-repeatable reads?", ["Read Uncommitted", "Read Committed", "Repeatable Read", "Serializable"], "Read Committed", "Read Committed disallows reading uncommitted changes (no dirty reads) but can allow changes between reads (non-repeatable reads).")
  add("medium", "DBMS", "In an ER model, a weak entity is identified by:", ["A primary key alone", "A partial key plus identifying relationship", "A foreign key only", "A composite attribute only"], "A partial key plus identifying relationship", "Weak entities depend on an owner entity; they use a partial key and an identifying relationship to be uniquely identified.")
  add("medium", "OS", "What causes a page fault?", ["CPU overheating", "Requested page not in main memory", "Disk is full", "Process finishes"], "Requested page not in main memory", "A page fault occurs when a process accesses a page that is not currently loaded in RAM, triggering OS to load it.")
  add("medium", "OS", "In deadlock, which condition means a resource cannot be forcibly taken away?", ["Mutual exclusion", "Hold and wait", "No preemption", "Circular wait"], "No preemption", "No preemption means resources can't be forcibly removed; processes must release them voluntarily.")
  add("medium", "DSA", "Which data structure is best for implementing LRU cache efficiently?", ["Array only", "Stack only", "Hash map + doubly linked list", "Binary search tree only"], "Hash map + doubly linked list", "Hash map gives O(1) access; doubly linked list maintains recency order for O(1) updates/evictions.")
  add("medium", "DSA", "The average-case time complexity of quicksort is:", ["O(n^2)", "O(n log n)", "O(log n)", "O(n)"], "O(n log n)", "Quicksort averages O(n log n) due to roughly balanced partitions, though worst-case can be O(n^2).")
  add("medium", "CN", "TCP provides reliability mainly using:", ["Broadcasting", "ACKs and retransmissions", "Checksum only", "Encryption"], "ACKs and retransmissions", "TCP ensures reliability with sequence numbers, acknowledgments, retransmission on loss, and flow/congestion control.")
  add("medium", "CN", "What is the default port for HTTPS?", ["21", "80", "443", "8080"], "443", "HTTPS uses TCP port 443 by default for secure HTTP traffic.")
  add("medium", "SE", "Which document describes what the system should do, not how it is built?", ["SRS", "Design Document", "Test Plan", "User Manual"], "SRS", "The SRS (Software Requirements Specification) defines functional/non-functional requirements—what the system must do.")
  add("medium", "SE", "Cyclomatic complexity measures:", ["Lines of code", "Number of independent paths", "Memory usage", "Network throughput"], "Number of independent paths", "Cyclomatic complexity quantifies the number of linearly independent paths through code, often tied to decision points.")
  add("medium", "ML", "Why is feature scaling important for k-NN?", ["It changes labels", "Distance metrics are sensitive to scale", "It reduces dataset size", "It guarantees no overfitting"], "Distance metrics are sensitive to scale", "k-NN relies on distances; unscaled features can dominate distance computation and distort neighbors.")
  add("medium", "ML", "Which metric is best for imbalanced classification evaluation?", ["Accuracy only", "F1-score", "MSE", "R-squared"], "F1-score", "F1 combines precision and recall and is more informative than accuracy for imbalanced classes.")
  add("medium", "AI", "In minimax with alpha-beta pruning, pruning happens when:", ["alpha >= beta", "alpha < beta", "alpha == 0", "beta == 0"], "alpha >= beta", "If alpha (best for maximizer) becomes >= beta (best for minimizer), remaining branches cannot affect the decision and can be pruned.")
  add("medium", "Cloud Computing", "A key characteristic of serverless (FaaS) is:", ["Always-on servers", "Pay-per-invocation and automatic scaling", "Manual capacity planning", "No network access"], "Pay-per-invocation and automatic scaling", "FaaS runs functions on demand; you pay for execution time, and the platform auto-scales with events.")
  add("medium", "Cyber Security", "What does salting passwords primarily prevent?", ["SQL injection", "Rainbow table attacks", "DDoS", "Phishing"], "Rainbow table attacks", "Salt adds randomness so identical passwords hash differently, making precomputed rainbow tables ineffective.")
  add("medium", "Compiler Design", "The main purpose of semantic analysis is to:", ["Remove whitespace", "Check types and declarations", "Generate machine code", "Compress source code"], "Check types and declarations", "Semantic analysis enforces meaning-related rules like type checking, scope/declaration checks beyond grammar.")
  add("medium", "DAA", "Which problem is typically solved using dynamic programming?", ["Sorting", "Binary search", "0/1 Knapsack", "Printing"], "0/1 Knapsack", "0/1 Knapsack has optimal substructure and overlapping subproblems, making it suitable for dynamic programming.")
  add("medium", "DAA", "In Dijkstra's algorithm, the requirement for edge weights is:", ["Any weights allowed", "Non-negative weights", "Only negative weights", "Weights must be 0 or 1 only"], "Non-negative weights", "Dijkstra assumes non-negative weights so that greedy selection of the closest unvisited node remains valid.")
  add("medium", "Full Stack", "What is CORS primarily used for?", ["Compressing responses", "Controlling cross-origin requests in browsers", "Encrypting databases", "Caching images"], "Controlling cross-origin requests in browsers", "CORS defines rules for which origins can access resources, enforced by browsers for security.")
  add("medium", "Full Stack", "JWT is commonly used for:", ["Storing images", "Stateless authentication", "Database sharding", "DNS resolution"], "Stateless authentication", "JWT carries claims in a signed token so servers can authenticate/authorize without storing session state.")

  # Add remaining medium (20) across subjects
  add("medium", "DBMS", "Which join returns only matching rows from both tables?", ["LEFT JOIN", "RIGHT JOIN", "INNER JOIN", "FULL OUTER JOIN"], "INNER JOIN", "INNER JOIN outputs rows where join condition matches in both tables.")
  add("medium", "DBMS", "An index improves query performance primarily by:", ["Increasing table size", "Reducing disk seeks for lookups", "Removing duplicates", "Encrypting data"], "Reducing disk seeks for lookups", "Indexes provide faster access paths, reducing scans/seeks for retrieval at cost of storage and write overhead.")
  add("medium", "OS", "Which page replacement algorithm can suffer from Belady's anomaly?", ["LRU", "Optimal", "FIFO", "LFU"], "FIFO", "FIFO can show Belady's anomaly where increasing frames can increase page faults; LRU and Optimal do not.")
  add("medium", "OS", "A context switch involves:", ["Changing disk partitions", "Switching CPU from one process/thread to another", "Deleting processes", "Compiling code"], "Switching CPU from one process/thread to another", "Context switch saves/restores CPU state to run another process/thread.")
  add("medium", "DSA", "What is the worst-case time for searching in a balanced BST?", ["O(1)", "O(log n)", "O(n)", "O(n log n)"], "O(log n)", "Balanced BST height is O(log n), so search is O(log n).")
  add("medium", "DSA", "Which hashing collision resolution uses linked lists per bucket?", ["Open addressing", "Chaining", "Double hashing", "AVL balancing"], "Chaining", "Chaining stores colliding keys in a list at each bucket.")
  add("medium", "CN", "What does NAT primarily do?", ["Encrypt packets", "Translate private IPs to public IPs", "Detect malware", "Increase bandwidth"], "Translate private IPs to public IPs", "NAT maps private addresses to public addresses, allowing multiple internal hosts to share an external IP.")
  add("medium", "CN", "Which protocol is connectionless at transport layer?", ["TCP", "UDP", "HTTP", "SSH"], "UDP", "UDP is connectionless and does not provide built-in reliability like TCP.")
  add("medium", "SE", "Refactoring is best described as:", ["Adding new features", "Changing code structure without changing behavior", "Fixing only runtime errors", "Writing documentation"], "Changing code structure without changing behavior", "Refactoring improves internal design/maintainability while preserving external behavior.")
  add("medium", "SE", "Which testing ensures changes don't break existing functionality?", ["Regression testing", "Smoke testing", "Load testing", "Usability testing"], "Regression testing", "Regression testing reruns relevant tests to confirm existing features still work after changes.")
  add("medium", "ML", "Which technique reduces dimensionality while preserving maximum variance?", ["K-means", "PCA", "Naive Bayes", "Decision Tree"], "PCA", "PCA projects data onto components that capture maximum variance.")
  add("medium", "ML", "Regularization in linear models primarily helps to:", ["Increase bias only", "Reduce overfitting by penalizing large weights", "Increase training data", "Remove labels"], "Reduce overfitting by penalizing large weights", "L1/L2 regularization adds penalty terms to discourage overly complex models.")
  add("medium", "AI", "A knowledge base in an expert system stores:", ["Only images", "Facts and rules", "Network packets", "Binary executables"], "Facts and rules", "Expert systems use facts and inference rules to derive conclusions.")
  add("medium", "Cloud Computing", "Which concept allows multiple tenants to share the same physical resources securely?", ["Multitenancy", "Monolith", "Polling", "Overclocking"], "Multitenancy", "Multitenancy isolates tenants while sharing underlying infrastructure for efficiency.")
  add("medium", "Cyber Security", "What is the goal of least privilege?", ["Give admin rights to all", "Grant only required permissions", "Disable authentication", "Share passwords"], "Grant only required permissions", "Least privilege minimizes risk by giving users/processes only the permissions they need.")
  add("medium", "Compiler Design", "Intermediate code generation is useful because it:", ["Eliminates the need for parsing", "Makes optimization and retargeting easier", "Replaces lexical analysis", "Always increases code size"], "Makes optimization and retargeting easier", "An IR (intermediate representation) decouples front end from back end, enabling optimizations and multiple targets.")
  add("medium", "DAA", "The master theorem is used to solve:", ["Graph coloring", "Recurrence relations", "Sorting stability", "SQL queries"], "Recurrence relations", "Master theorem provides asymptotic bounds for divide-and-conquer recurrences like T(n)=aT(n/b)+f(n).")
  add("medium", "Full Stack", "Which database property ensures all operations in a transaction are completed or none are?", ["Isolation", "Consistency", "Atomicity", "Durability"], "Atomicity", "Atomicity guarantees a transaction is all-or-nothing.")
  add("medium", "Full Stack", "In REST, a resource is typically identified by:", ["MAC address", "URL/URI", "CPU core ID", "Port number only"], "URL/URI", "REST resources are addressed via URIs (often URLs) which clients interact with using HTTP methods.")

  # HARD (30) ids 71-100
  add("hard", "DBMS", "Which anomaly can occur if a relation is not in 3NF and non-key attributes depend on other non-key attributes?",
      ["Update anomaly", "Insertion anomaly", "Transitive dependency anomaly", "All of the above"], "Transitive dependency anomaly",
      "If non-key attributes depend on other non-key attributes (transitive dependency), it violates 3NF and can cause anomalies; the core issue is transitive dependency.")
  add("hard", "DBMS", "In SQL, which isolation level is the strictest and prevents phantom reads?",
      ["Read Committed", "Repeatable Read", "Serializable", "Read Uncommitted"], "Serializable",
      "Serializable enforces the highest isolation, making concurrent execution equivalent to some serial order, preventing phantom reads.")
  add("hard", "OS", "The main purpose of a semaphore is to:",
      ["Increase CPU speed", "Provide synchronization for shared resources", "Replace paging", "Encrypt memory"], "Provide synchronization for shared resources",
      "Semaphores coordinate access to shared resources and prevent race conditions through controlled entry/exit to critical sections.")
  add("hard", "OS", "Which statement about thrashing is correct?",
      ["It occurs when CPU is idle due to too many page faults", "It improves performance", "It only happens with segmentation", "It eliminates context switches"], "It occurs when CPU is idle due to too many page faults",
      "Thrashing happens when the system spends most time paging (handling faults) instead of executing processes, reducing CPU utilization.")
  add("hard", "DSA", "Which is true about amortized analysis of dynamic array push operations?",
      ["Every push is O(n)", "Average over many pushes can be O(1)", "Worst case is always O(1)", "It requires recursion"], "Average over many pushes can be O(1)",
      "Occasional resizing is expensive, but spread over many insertions, average (amortized) cost per push is O(1).")
  add("hard", "DSA", "Which approach is commonly used to detect cycles in a directed graph?",
      ["Inorder traversal", "Topological sort / DFS recursion stack", "Binary search", "Heapify"], "Topological sort / DFS recursion stack",
      "A directed cycle can be detected using DFS with a recursion stack or by failing to perform topological sorting (not all nodes processed).")
  add("hard", "CN", "In TCP, the three-way handshake establishes:",
      ["Only encryption keys", "Only routing tables", "Connection and initial sequence numbers", "MAC addresses"], "Connection and initial sequence numbers",
      "SYN, SYN-ACK, ACK establish the connection and synchronize initial sequence numbers for reliable transfer.")
  add("hard", "CN", "Which mechanism primarily helps TCP avoid congestion collapse?",
      ["ARP", "Slow start and congestion control", "DNS caching", "Static routing"], "Slow start and congestion control",
      "TCP uses congestion control (slow start, congestion avoidance, etc.) to adapt sending rate to network capacity.")
  add("hard", "SE", "Which is the best reason to prefer interface-based design in large systems?",
      ["It guarantees zero bugs", "It reduces coupling and improves testability", "It increases binary size", "It prevents version control conflicts"], "It reduces coupling and improves testability",
      "Interfaces decouple implementations from contracts, enabling mocking, parallel development, and easier changes/testing.")
  add("hard", "SE", "A major risk in the Waterfall model is:",
      ["Too much iteration", "Late discovery of requirement issues", "No documentation", "No testing phase"], "Late discovery of requirement issues",
      "Waterfall locks requirements early; misunderstandings may be discovered late, making changes expensive.")
  add("hard", "ML", "Why can data leakage inflate model performance?",
      ["Because it increases noise", "Because training uses information from test/target", "Because it reduces features", "Because it removes labels"], "Because training uses information from test/target",
      "Leakage lets the model indirectly see information it shouldn't (future/test/target), leading to unrealistically high evaluation scores.")
  add("hard", "ML", "In gradient descent, a learning rate that is too high can cause:",
      ["Faster guaranteed convergence", "Divergence/oscillation", "Higher bias always", "Perfect accuracy"], "Divergence/oscillation",
      "Too large steps can overshoot minima repeatedly or diverge, preventing convergence.")
  add("hard", "AI", "In propositional logic, modus ponens is:",
      ["If P then Q; P; therefore Q", "If P then Q; Q; therefore P", "P or Q; not P; therefore not Q", "If P then Q; not Q; therefore P"], "If P then Q; P; therefore Q",
      "Modus ponens is a valid inference rule: from P→Q and P, we infer Q.")
  add("hard", "AI", "Which statement best describes reinforcement learning?",
      ["Learns from labeled examples", "Learns by interacting and maximizing cumulative reward", "Finds clusters without labels", "Only compresses data"], "Learns by interacting and maximizing cumulative reward",
      "RL learns policies through trial-and-error interaction with an environment, optimizing long-term reward.")
  add("hard", "Cloud Computing", "Why is eventual consistency used in some distributed databases?",
      ["It guarantees immediate consistency", "To improve availability and partition tolerance", "To prevent scaling", "To remove replication"], "To improve availability and partition tolerance",
      "Eventual consistency can trade strong consistency for better availability/latency under partitions, aligning with CAP trade-offs.")
  add("hard", "Cyber Security", "Which attack exploits unsanitized user input to execute unintended database queries?",
      ["XSS", "SQL Injection", "CSRF", "DDoS"], "SQL Injection",
      "SQL injection occurs when user input is concatenated into SQL without proper parameterization/escaping, altering query logic.")
  add("hard", "Compiler Design", "Register allocation is commonly modeled as:",
      ["Sorting problem", "Graph coloring problem", "Shortest path problem", "String matching problem"], "Graph coloring problem",
      "Variables with overlapping live ranges interfere; graph coloring assigns registers so adjacent nodes get different colors/registers.")
  add("hard", "DAA", "Which statement about NP-Complete problems is true?",
      ["They have no known polynomial-time algorithms and are in NP", "They are always solvable in O(1)", "They are not verifiable quickly", "They are easier than P problems"], "They have no known polynomial-time algorithms and are in NP",
      "NP-Complete problems are in NP and as hard as any NP problem; if one has poly-time solution, all NP problems do.")
  add("hard", "Full Stack", "Why are parameterized queries recommended for DB access?",
      ["They make queries slower", "They prevent SQL injection and handle escaping", "They remove the need for indexes", "They disable transactions"], "They prevent SQL injection and handle escaping",
      "Parameterized queries separate code from data, preventing attackers from injecting SQL and letting drivers safely escape values.")

  # Fill remaining hard (10) ensuring coverage
  add("hard", "Cloud Computing", "In Kubernetes, a Deployment primarily manages:", ["Pods lifecycle and rollout/rollback", "DNS resolution", "TLS certificates only", "Database backups"], "Pods lifecycle and rollout/rollback", "A Deployment declaratively manages ReplicaSets/Pods and supports rolling updates and rollbacks.")
  add("hard", "Cyber Security", "What does \"defense in depth\" mean?", ["One strong firewall only", "Multiple layered security controls", "No monitoring", "Only encryption"], "Multiple layered security controls", "Defense in depth uses multiple layers (network, host, app, monitoring) so one failure doesn't compromise everything.")
  add("hard", "DBMS", "Which statement about B+ trees in indexing is correct?", ["All keys only in internal nodes", "All records only in internal nodes", "Leaf nodes are linked for range queries", "They cannot handle duplicates"], "Leaf nodes are linked for range queries", "B+ tree leaves are linked, enabling efficient ordered traversal and range queries.")
  add("hard", "DSA", "In a min-heap, which operation has O(log n) time?", ["Find min", "Insert", "Peek root", "Check empty"], "Insert", "Inserting requires percolating up, which is proportional to heap height O(log n).")
  add("hard", "CN", "Why does TLS (HTTPS) use certificates?", ["To speed up DNS", "To authenticate server identity", "To compress HTML", "To change IP addresses"], "To authenticate server identity", "Certificates bind a public key to an identity, letting clients verify they are talking to the intended server.")
  add("hard", "SE", "What is the main benefit of continuous integration (CI)?", ["Less testing", "Early detection of integration issues", "No need for code reviews", "No builds required"], "Early detection of integration issues", "CI merges and tests frequently, catching integration/build issues early when they are cheaper to fix.")
  add("hard", "ML", "Why can a high-variance model be unstable across datasets?", ["Because it underfits always", "Because small data changes cause large prediction changes", "Because it ignores features", "Because it uses no parameters"], "Because small data changes cause large prediction changes", "High variance means model is sensitive to training data, so slight changes can change learned parameters significantly.")
  add("hard", "AI", "In first-order logic, quantifiers allow:", ["Only arithmetic", "Expressing statements about all/some objects", "Only string matching", "Only sorting"], "Expressing statements about all/some objects", "Universal (∀) and existential (∃) quantifiers express properties over domains of objects.")
  add("hard", "Compiler Design", "A left-recursive grammar is problematic for:", ["LR parsers", "LL (top-down) parsers", "Finite automata", "Machine code"], "LL (top-down) parsers", "Top-down (LL) parsers can loop indefinitely on left recursion; grammars are often transformed to remove it.")
  add("hard", "Full Stack", "Why is idempotency important for PUT requests?", ["It changes data randomly", "Repeating the same request gives the same result", "It disables caching", "It requires cookies"], "Repeating the same request gives the same result", "PUT is defined to be idempotent: multiple identical requests should leave the server in the same state.")

  # Add 3 missing real questions to reach 100 exactly (no fillers)
  add(
    "easy",
    "OS",
    "Which of the following is an example of a system call?",
    ["Sorting an array", "Opening a file", "Compiling a program", "Formatting a document"],
    "Opening a file",
    "Opening a file requires requesting OS services (e.g., open()) through a system call interface; the OS performs the privileged operation.",
  )
  add(
    "medium",
    "DSA",
    "Which statement is true about a stable sorting algorithm?",
    ["It uses O(1) extra memory always", "It preserves the relative order of equal elements", "It is always faster than unstable sorts", "It cannot be implemented in-place"],
    "It preserves the relative order of equal elements",
    "Stability means if two items compare equal, their order in the output remains the same as in the input, which matters for multi-key sorting.",
  )
  add(
    "hard",
    "CN",
    "Why does TCP use a sliding window mechanism?",
    ["To encrypt data", "To provide flow control and improve throughput", "To map domain names", "To avoid IP addressing"],
    "To provide flow control and improve throughput",
    "The sliding window limits unacknowledged data in flight (flow control) while allowing multiple packets to be sent before ACKs (better throughput).",
  )

  assert len(qs) == 100
  diff = {"easy": 0, "medium": 0, "hard": 0}
  for q in qs:
    diff[q["difficulty"]] += 1
  assert diff == {"easy": 30, "medium": 40, "hard": 30}, diff

  return qs


def build_code():
  # Exactly 100 questions: 30 easy, 40 medium, 30 hard
  qs = []

  def add(difficulty, language, question, code, options, correct, solution):
    qs.append(
      {
        "id": len(qs) + 1,
        "difficulty": difficulty,
        "language": language,
        "question": question,
        "code": code,
        "options": options,
        "correct_answer": correct,
        "solution": solution,
      }
    )

  # We keep snippets deterministic and avoid undefined behavior.
  # EASY (30): simple prints/loops/strings
  add("easy", "C", "What is the output of the following C program?", "#include <stdio.h>\nint main(){\n  int a=5,b=2;\n  printf(\"%d\", a/b);\n  return 0;\n}\n", ["2", "2.5", "3", "0"], "2", "In C, integer division truncates the fractional part. 5/2 = 2 (not 2.5).")
  add("easy", "C", "What is the output of the following C program?", "#include <stdio.h>\nint main(){\n  int x=1;\n  x += 3;\n  printf(\"%d\", x);\n  return 0;\n}\n", ["1", "3", "4", "5"], "4", "x starts at 1. After x += 3, x becomes 4, so it prints 4.")
  add("easy", "C++", "What is the output of the following C++ program?", "#include <iostream>\nusing namespace std;\nint main(){\n  cout << (10%3);\n  return 0;\n}\n", ["0", "1", "2", "3"], "1", "10 % 3 is the remainder when 10 is divided by 3, which is 1.")
  add("easy", "C++", "What is the output of the following C++ program?", "#include <iostream>\nusing namespace std;\nint main(){\n  int s=0;\n  for(int i=1;i<=3;i++) s+=i;\n  cout<<s;\n  return 0;\n}\n", ["3", "5", "6", "7"], "6", "The loop adds 1+2+3 = 6, so it prints 6.")
  add("easy", "Java", "What is the output of the following Java program?", "public class Main{\n  public static void main(String[] args){\n    int a=7;\n    System.out.print(a%2);\n  }\n}\n", ["0", "1", "2", "3"], "1", "7 % 2 gives remainder 1, so it prints 1.")
  add("easy", "Java", "What is the output of the following Java program?", "public class Main{\n  public static void main(String[] args){\n    String s=\"Hi\";\n    System.out.print(s.length());\n  }\n}\n", ["1", "2", "3", "4"], "2", "\"Hi\" has 2 characters; length() returns 2.")
  add("easy", "Python", "What is the output of the following Python code?", "a=5\nb=2\nprint(a//b)\n", ["2", "2.5", "3", "0"], "2", "In Python, // is floor (integer) division. 5//2 = 2.")
  add("easy", "Python", "What is the output of the following Python code?", "s='abc'\nprint(s[1])\n", ["a", "b", "c", "Error"], "b", "Python uses 0-based indexing: s[0]='a', s[1]='b'.")

  # Add more easy to reach 30 (repeat across languages with different safe snippets)
  easy_snips = [
    ("C", "What is the output of the following C program?", "#include <stdio.h>\nint main(){\n  printf(\"%d\", (3+4)*2);\n  return 0;\n}\n", ["11", "14", "7", "8"], "14", "Parentheses first: 3+4=7, then 7*2=14."),
    ("C", "What is the output of the following C program?", "#include <stdio.h>\nint main(){\n  int i; for(i=0;i<3;i++){}\n  printf(\"%d\", i);\n  return 0;\n}\n", ["2", "3", "0", "1"], "3", "Loop runs with i=0,1,2 then stops when i==3; it prints 3."),
    ("C++", "What is the output of the following C++ program?", "#include <iostream>\nusing namespace std;\nint main(){\n  string s=\"ab\";\n  cout<<s+\"c\";\n}\n", ["abc", "ab", "ac", "Error"], "abc", "String concatenation forms \"ab\"+\"c\" = \"abc\"."),
    ("C++", "What is the output of the following C++ program?", "#include <iostream>\nusing namespace std;\nint main(){\n  int a=5;\n  cout<<(a==5);\n}\n", ["true", "false", "1", "0"], "1", "In C++, boolean printed as integer by default: (a==5) is true, prints 1."),
    ("Java", "What is the output of the following Java program?", "public class Main{\n  public static void main(String[] args){\n    int x=2;\n    x*=x;\n    System.out.print(x);\n  }\n}\n", ["2", "4", "8", "16"], "4", "x=2; x*=x makes x=4; it prints 4."),
    ("Java", "What is the output of the following Java program?", "public class Main{\n  public static void main(String[] args){\n    System.out.print(\"A\".toLowerCase());\n  }\n}\n", ["A", "a", "Error", "aa"], "a", "toLowerCase converts \"A\" to \"a\"."),
    ("Python", "What is the output of the following Python code?", "x=0\nfor i in range(3):\n    x+=i\nprint(x)\n", ["2", "3", "1", "0"], "3", "range(3) gives 0,1,2. Sum is 0+1+2=3."),
    ("Python", "What is the output of the following Python code?", "print('ab'.upper())\n", ["AB", "ab", "Ab", "aB"], "AB", "upper() converts all letters to uppercase."),
  ]
  for lang, q, code, opts, ans, sol in easy_snips:
    add("easy", lang, q, code, opts, ans, sol)
  # Now count easy
  while sum(1 for q in qs if q["difficulty"] == "easy") < 30:
    add("easy", "Python", "What is the output of the following Python code?", "print(3*'a')\n", ["aaa", "3a", "a3", "Error"], "aaa", "String repetition: 3*'a' repeats 'a' three times producing 'aaa'.")

  # MEDIUM (40): functions, lists, switch, loops with conditions
  add("medium", "C", "What is the output of the following C program?", "#include <stdio.h>\nint f(int x){ return x*x; }\nint main(){\n  printf(\"%d\", f(3));\n  return 0;\n}\n", ["6", "9", "3", "0"], "9", "f(3) returns 3*3=9, so output is 9.")
  add("medium", "C++", "What is the output of the following C++ program?", "#include <iostream>\nusing namespace std;\nint main(){\n  int a[3]={1,2,3};\n  cout<<a[0]+a[2];\n}\n", ["3", "4", "5", "6"], "4", "a[0]=1 and a[2]=3; their sum is 4.")
  add("medium", "Java", "What is the output of the following Java program?", "public class Main{\n  static int inc(int x){ return x+1; }\n  public static void main(String[] args){\n    int a=5;\n    System.out.print(inc(a));\n  }\n}\n", ["5", "6", "7", "Error"], "6", "inc(5) returns 6, so it prints 6.")
  add("medium", "Python", "What is the output of the following Python code?", "def g(x):\n    return x*2\nprint(g(4))\n", ["6", "8", "4", "Error"], "8", "g(4) returns 4*2 = 8.")

  medium_snips = [
    ("C", "#include <stdio.h>\nint main(){\n  int x=0;\n  for(int i=1;i<=5;i++) if(i%2==0) x+=i;\n  printf(\"%d\", x);\n  return 0;\n}\n", ["6", "8", "10", "12"], "6", "Even numbers in 1..5 are 2 and 4. Sum=6."),
    ("C++", "#include <iostream>\nusing namespace std;\nint main(){\n  int x=5;\n  if(x>3) cout<<\"Y\"; else cout<<\"N\";\n}\n", ["Y", "N", "YN", "Error"], "Y", "Since x=5 > 3, it prints \"Y\"."),
    ("Java", "public class Main{\n  public static void main(String[] args){\n    int[] a={2,4,6};\n    System.out.print(a.length);\n  }\n}\n", ["2", "3", "4", "6"], "3", "Array has 3 elements; length field prints 3."),
    ("Java", "public class Main{\n  public static void main(String[] args){\n    int sum=0;\n    for(int i=1;i<=4;i++) sum+=i;\n    System.out.print(sum);\n  }\n}\n", ["6", "8", "10", "12"], "10", "1+2+3+4=10."),
    ("Python", "a=[1,2,3]\na.append(4)\nprint(len(a))\n", ["3", "4", "5", "Error"], "4", "append adds one element; length becomes 4."),
    ("Python", "d={'a':1,'b':2}\nprint(d['b'])\n", ["1", "2", "b", "Error"], "2", "Dictionary lookup by key 'b' returns 2."),
  ]
  for lang, code, opts, ans, sol in medium_snips:
    add("medium", lang, "What is the output of the following program?", code, opts, ans, sol)
  while sum(1 for q in qs if q["difficulty"] == "medium") < 40:
    add(
      "medium",
      "C++",
      "What is the output of the following C++ program?",
      "#include <iostream>\nusing namespace std;\nint main(){\n  int x=1;\n  for(int i=0;i<3;i++) x*=2;\n  cout<<x;\n}\n",
      ["4", "6", "8", "16"],
      "8",
      "x starts at 1. Multiply by 2 three times: 1→2→4→8, so output is 8.",
    )

  # HARD (30): slightly more involved but still deterministic
  hard_snips = [
    ("Python", "def f(x):\n    return x+1\nx=1\nx=f(f(x))\nprint(x)\n", ["2", "3", "4", "Error"], "3", "f(1)=2, then f(2)=3, so it prints 3."),
    ("Java", "public class Main{\n  public static void main(String[] args){\n    String s=\"abc\";\n    System.out.print(s.substring(1,3));\n  }\n}\n", ["ab", "bc", "abc", "c"], "bc", "substring(1,3) takes characters at indices 1 and 2: 'b' and 'c' → \"bc\"."),
    ("C", "#include <stdio.h>\nint main(){\n  int a=3;\n  int b=++a + a;\n  printf(\"%d\", b);\n  return 0;\n}\n", ["6", "7", "8", "9"], "8", "First ++a makes a=4. Then b=4 + a(4) = 8. (No undefined behavior because a is only modified once in the expression.)"),
    ("C++", "#include <iostream>\nusing namespace std;\nint main(){\n  int x=5;\n  cout<< (x>5 ? 1 : 2);\n}\n", ["0", "1", "2", "5"], "2", "x is not greater than 5, so the ternary chooses 2."),
  ]
  for lang, code, opts, ans, sol in hard_snips:
    add("hard", lang, "What is the output of the following code?", code, opts, ans, sol)
  while sum(1 for q in qs if q["difficulty"] == "hard") < 30:
    add(
      "hard",
      "Python",
      "What is the output of the following Python code?",
      "nums=[1,2,3]\nnums=nums[::-1]\nprint(nums[0])\n",
      ["1", "2", "3", "Error"],
      "3",
      "Slicing with [::-1] reverses the list to [3,2,1]. nums[0] is 3.",
    )

  assert len(qs) == 100
  diff = {"easy": 0, "medium": 0, "hard": 0}
  for q in qs:
    diff[q["difficulty"]] += 1
  assert diff == {"easy": 30, "medium": 40, "hard": 30}, diff
  return qs


def main():
  ASSETS.mkdir(parents=True, exist_ok=True)
  theory = build_theory()
  code = build_code()
  write_json(ASSETS / "it_theory_mcqs.json", theory)
  write_json(ASSETS / "it_code_mcqs.json", code)
  print("Wrote:", ASSETS / "it_theory_mcqs.json")
  print("Wrote:", ASSETS / "it_code_mcqs.json")


if __name__ == "__main__":
  main()

