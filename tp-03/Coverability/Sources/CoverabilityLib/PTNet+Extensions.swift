import PetriKit

public extension PTNet {

    /// Computes the coverability graph of this P/T-net, starting from the given marking.
    ///
    /// Implementation note:
    /// It is easier to build the coverability graph in a recursive depth-first manner than with
    /// stacks, because we need to keep track of predecessor nodes as we process new ones. That's
    /// why the algorithm is actually implemented in `computeSuccessors(of:_:_:)`.
    public func coverabilityGraph(from marking: CoverabilityMarking) -> CoverabilityGraph {

        // Write here the implementation of the coverability graph generation.

        // An array of `CoverabilityGraph` instances that keeps track of the nodes we've already
        // visited. It initially contains the initial node of the coverability graph.
        var seen = [initialNode]

        // Compute the successors of the initial node. Notice that we pass a reference to the array
        // of visited nodes, and an initially empty array of predecessors.
        self.computeSuccessors(of: initialNode, seen: &seen, predecessors: [])

				let transitions = self.transitions
				let initNode = CoverabilityGraph(marking: marking)
        var toVisit = [CoverabilityGraph]()
        var visited = [CoverabilityGraph]()

        toVisit.append(initNode)

				while toVisit.count != 0 {
            let cur = toVisit.removeFirst()
            visited.append(cur)
            transitions.forEach { trans in
              if var newMark = trans.fire(from: cur.marking) {
                newMark = checkOmega(mark : newMark, list : visited)
                if let alreadyVisited = visited.first(where: { $0.marking == newMark }) {
                    cur.successors[trans] = alreadyVisited
                }
								else {
                    let discovered = CoverabilityGraph(marking: newMark)
                    cur.successors[trans] = discovered
                    if (!toVisit.contains(where: { $0.marking == discovered.marking})) {
                        toVisit.append(discovered)
                    }
                }
              }
            }
        }
        return initNode
    }

    // checks if a merking is bigger than a previous one and set omega conscequently
    private func checkOmega(mark : CoverabilityMarking, list : [CoverabilityGraph]) -> CoverabilityMarking {
      var ret = mark
      for pastNode in list {
          if ret > pastNode.marking{
            for place in ret.keys {
                if ret[place]! > pastNode.marking[place]! {
                  ret[place] = .omega
                }
            }
            return ret
          }
      }
      return mark
    }
}

/*
  Extension of PTTransition to implemnet isFireable and fire with a CoverabilityMarking
*/
public extension PTTransition {

	public func isFireable(from marking: CoverabilityMarking) -> Bool {
		for arc in self.preconditions {
      if case .some(let nb) = marking[arc.place]! {
        if nb < arc.tokens{
          return false
        }
			}
		}
    return true
	}

	public func fire(from marking: CoverabilityMarking) -> CoverabilityMarking? {
		guard self.isFireable(from: marking) else {
        return nil
		}
		var result = marking

		for arc in self.preconditions {
			if case .some(let nb) = result[arc.place]! {
				result[arc.place]! = .some(nb - arc.tokens)
			}
		}
		for arc in self.postconditions {
			if case .some(let nb) = result[arc.place]! {
				result[arc.place]! = .some(nb + arc.tokens)
			}
		}
		return result
	}
}
