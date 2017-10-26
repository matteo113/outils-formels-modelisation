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


    /*
      Given a MarkingGraph it returns the number of nodes in the graph
    */
    public func count (mark: MarkingGraph) -> Int{
      var seen = [MarkingGraph]()
      var toSee = [MarkingGraph]()
      var unique = [MarkingGraph]()

      toSee.append(mark)
      while let cur = toSee.popLast() {
        seen.append(cur)
        for(_, successor) in cur.successors{
          if !seen.contains(where: {$0 === successor}) && !toSee.contains(where: {$0 === successor}){
              toSee.append(successor)
            }
          }
      }
      for state in seen {
          if(!unique.contains(where :{$0.marking == state.marking})){
            unique.append(state)
          }
      }
      return unique.count
    }

    /*
      Given a MarkingGraph it returns true if it exists a node where more than
      two smokers are smoking at the same time.
    */
    public func moreThanTwo (mark: MarkingGraph) -> Bool {
      var seen = [MarkingGraph]()
      var toSee = [MarkingGraph]()

      toSee.append(mark)
      while let cur = toSee.popLast() {
        seen.append(cur)
        var nbSmoke = 0;
        for (key, value) in cur.marking {
            if (key.name == "s1" || key.name == "s2" || key.name == "s3"){
               nbSmoke += Int(value)
            }
        }
        if (nbSmoke > 1) {
          //print (cur.marking)
          return true
        }
        for(_, successor) in cur.successors{
          if !seen.contains(where: {$0 === successor}) && !toSee.contains(where: {$0 === successor}){
              toSee.append(successor)
            }
          }
      }
      return false
    }
    /*
      Given a MarkingGraph it returns true if it exists a node where there is more
      than one times the same item on the table
    */
    public func twoTimesSame (mark: MarkingGraph) -> Bool {
      var seen = [MarkingGraph]()
      var toSee = [MarkingGraph]()

      toSee.append(mark)
      while let cur = toSee.popLast() {
        seen.append(cur)
        for (key, value) in cur.marking {
            if (key.name == "p" || key.name == "t" || key.name == "m"){
               if(value > 1){
               //print(cur.marking)
                 return true
               }
            }
        }
        for(_, successor) in cur.successors{
          if !seen.contains(where: {$0 === successor}) && !toSee.contains(where: {$0 === successor}){
              toSee.append(successor)
            }
          }
      }
      return false
    }

}
