import PetriKit

public extension PTNet {

    public func coverabilityGraph(from marking: CoverabilityMarking) -> CoverabilityGraph {

        // Write here the implementation of the coverability graph generation.

        // Note that CoverabilityMarking implements both `==` and `>` operators, meaning that you
        // may write `M > N` (with M and N instances of CoverabilityMarking) to check whether `M`
        // is a greater marking than `N`.

        // IMPORTANT: Your function MUST return a valid instance of CoverabilityGraph! The optional
        // print debug information you'll write in that function will NOT be taken into account to
        // evaluate your homework.

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
