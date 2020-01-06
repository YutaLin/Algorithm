func example(of example: String, implementation: () -> ()) {
    print(example)
    implementation()
}

// MARK - Node

public class Node<Value> {
    
    public var value: Value
    public var next: Node?
    
    public init(value: Value, next: Node? = nil) {
        self.value = value
        self.next = next
    }
}

extension Node: CustomStringConvertible {
    
    public var description: String {
        guard let next = next else {
            return "\(value)"
        }
        
        return "\(value) -> " + String(describing: next) + " "
    }
}

example(of: "creating and linking nodes") {
    
    let node1 = Node(value: 1)
    let node2 = Node(value: 2)
    let node3 = Node(value: 3)
    
    node1.next = node2
    node2.next = node3
    
    print(node1)
}

// MARK - Linked List

public struct LinkedList<Value> {
    
    public var head: Node<Value>?
    
    public var tail: Node<Value>?
    
    public init() {}
    
    public var isEmpty: Bool {
        return head == nil
    }
    
    public mutating func push(_ value: Value) {
        head = Node(value: value, next: head)
        if tail == nil {
            tail = head
        }
    }
    
    public mutating func append(_ value: Value) {
        guard !isEmpty else {
            push(value)
            return
        }
        
        tail?.next = Node(value: value)
        
        tail = tail?.next
    }
    
    public func node(at index: Int) -> Node<Value>? {
        var currentNode = head
        var currentIndex = 0
        
        while currentNode != nil && currentIndex < index {
            currentNode = currentNode?.next
            currentIndex += 1
        }
        
        return currentNode
    }
    
    public mutating func insert(_ value: Value, after node: Node<Value>) {
        guard tail !== node else {
            append(value)
            return
        }
        
        node.next = Node(value: value, next: node.next)
    }
    
    @discardableResult
    public mutating func pop() -> Value? {
        defer {
            head = head?.next
            if !isEmpty {
                tail = nil
            }
        }
        
        return head?.value
    }
    
    @discardableResult
    public mutating func removeLast() -> Value? {
        guard let head = head else {
            return nil
        }
        
        guard head.next != nil else {
            return pop()
        }
        
        var prev = head
        var current = head
        
        while let next = current.next {
            prev = current
            current = next
        }
        
        prev.next = nil
        tail = prev
        return current.value
    }
    
    @discardableResult
    public mutating func remove(after node: Node<Value>) -> Value? {
        defer {
            if tail === node.next {
                tail = node
            }
            node.next = node.next?.next
        }
        
        return node.next?.value
    }
}

extension LinkedList: CustomStringConvertible {
    
    public var description: String {
        guard let head = head else {
            return "Empty List"
        }
        
        return String(describing: head)
    }
}

example(of: "push") {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(4)
    list.push(5)
    
    print(list)
}

example(of: "append") {
    var list = LinkedList<Int>()
    list.append(3)
    list.append(4)
    list.append(5)
    
    print(list)
}

example(of: "insert") {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    
    print("Before inserting \(list)")
    let middleNode = list.node(at: 1)!
    
    for _ in 1...2 {
        list.insert(0, after: middleNode)
    }
    
    print("After inserting \(list)")
}

example(of: "pop") {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    
    list.pop()
    
    print(list)
}

example(of: "removing the last node") {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    
    print("Before removing last node: \(list)")
    let removedValue = list.removeLast()
    
    print("After removing last node: \(list)")
    print("Remove value: " + String(describing: removedValue))
}

example(of: "removing a node after a particular node") {
  var list = LinkedList<Int>()
  list.push(3)
  list.push(2)
  list.push(1)
  
  print("Before removing at particular index: \(list)")
  let index = 1
  let node = list.node(at: index - 1)!
  let removedValue = list.remove(after: node)
  
  print("After removing at index \(index): \(list)")
  print("Removed value: " + String(describing: removedValue))
}

extension LinkedList: Collection {

    public struct Index: Comparable {

        public var node: Node<Value>?

        static public func ==(lhs: Index, rhs: Index) -> Bool {
            switch (lhs.node, rhs.node) {
            case let (left?, right?):
                return left.next === right.next
            case (nil, nil):
                return true
            default:
                return false
            }
        }

        static public func <(lhs: Index, rhs: Index) -> Bool {
            guard lhs != rhs else {
                return false
            }

            let nodes = sequence(first: lhs.node) { $0?.next }
            return nodes.contains { $0 === rhs.node }
        }
    }

    public var startIndex: Index {
      return Index(node: head)
    }
    
    public var endIndex: Index {
      return Index(node: tail?.next)
    }
    
    public func index(after i: Index) -> Index {
      return Index(node: i.node?.next)
    }
    
    public subscript(position: Index) -> Value {
      return position.node!.value
    }
}

example(of: "using collection") {
    var list = LinkedList<Int>()
    
    for i in 0...9 {
        list.append(i)
    }
    
    print("List: \(list)")
    print("First element: \(list[list.startIndex])")
    print("Array containing first 3 elements: \(Array(list.prefix(3)))")
    print("Array containing last 3 elements: \(Array(list.suffix(3)))")
    
    let sum = list.reduce(0, +)
    print("sum of all values: \(sum)")
}
