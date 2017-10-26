import PetriKit

public class MarkingGraph {

    public let marking   : PTMarking
    public var successors: [PTTransition: MarkingGraph]

    public init(marking: PTMarking, successors: [PTTransition: MarkingGraph] = [:]) {
        self.marking    = marking
        self.successors = successors
    }

}

public extension PTNet {

    public func markingGraph(from marking: PTMarking) -> MarkingGraph? {
        // Write here the implementation of the marking graph generation.

        let transitions = self.transitions
        let initNode = MarkingGraph(marking: marking)
        var toVisit = [MarkingGraph]()
        var visited = [MarkingGraph]()

        toVisit.append(initNode)

        while toVisit.count != 0 {
            let cur = toVisit.removeFirst()
            visited.append(cur)
            transitions.forEach { trans in
              if let newMark = trans.fire(from: cur.marking) {
                        if let alreadyVisited = visited.first(where: { $0.marking == newMark }) {
                            cur.successors[trans] = alreadyVisited
                        } else {
                            let discovered = MarkingGraph(marking: newMark)
                            cur.successors[trans] = discovered
                            if (!toVisit.contains(where: { $0.marking == discovered.marking})) {
                                toVisit.append(discovered)
                            }
                    }
                }
            }
        }

        //initNode.nbNodes = visited.count

        return initNode
    }

    public func count (mark: MarkingGraph) -> Int{
      var seen = [MarkingGraph]()
      var toSee = [MarkingGraph]()

      toSee.append(mark)
      while let cur = toSee.popLast() {
        seen.append(cur)
        for(_, successor) in cur.successors{
          if !seen.contains(where: {$0 === successor}) && !toSee.contains(where: {$0 === successor}){
              toSee.append(successor)
            }
          }
      }
      /*for e in seen {
          print(e.marking)
          print(e.successors)
      }*/
      return seen.count
    }
}
