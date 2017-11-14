import PetriKit

public class CoverabilityGraph {

    public init(
        marking: CoverabilityMarking, successors: [PTTransition: CoverabilityGraph] = [:])
    {
        self.marking    = marking
        self.successors = successors
    }

    public let marking   : CoverabilityMarking
    public var successors: [PTTransition: CoverabilityGraph]

    /// The number of nodes in the graph.
    public var count: Int {
        var seen    = [self]
        var toCheck = [self]
        var unique = [CoverabilityGraph]()

        while let node = toCheck.popLast() {
            for (_, successor) in node.successors {
                if !seen.contains(where: { $0 === successor }) {
                    seen.append(successor)
                    toCheck.append(successor)
                }
            }
        }
        // without that this function counts several times the same node.
        for state in seen {
            if(!unique.contains(where :{$0.marking == state.marking})){
              unique.append(state)
            }
          }

        return unique.count
    }

}

extension CoverabilityGraph: Sequence {

    public func makeIterator() -> AnyIterator<CoverabilityGraph> {
        var seen    = [self]
        var toCheck = [self]

        return AnyIterator {
            guard let node = toCheck.popLast() else {
                return nil
            }

            let unvisited = node.successors.values.flatMap { successor in
                return seen.contains(where: { $0 === successor })
                    ? nil
                    : successor
            }

            seen.append(contentsOf: unvisited)
            toCheck.append(contentsOf: unvisited)

            return node
        }
    }

}
