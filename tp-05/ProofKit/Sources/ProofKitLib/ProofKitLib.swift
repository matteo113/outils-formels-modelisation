infix operator =>: LogicalDisjunctionPrecedence

public protocol BooleanAlgebra {

    static prefix func ! (operand: Self) -> Self
    static        func ||(lhs: Self, rhs: @autoclosure () throws -> Self) rethrows -> Self
    static        func &&(lhs: Self, rhs: @autoclosure () throws -> Self) rethrows -> Self

}

extension Bool: BooleanAlgebra {}

public enum Formula {

    /// p
    case proposition(String)

    /// ¬a
    indirect case negation(Formula)

    public static prefix func !(formula: Formula) -> Formula {
        return .negation(formula)
    }

    /// a ∨ b
    indirect case disjunction(Formula, Formula)

    public static func ||(lhs: Formula, rhs: Formula) -> Formula {
        return .disjunction(lhs, rhs)
    }

    /// a ∧ b
    indirect case conjunction(Formula, Formula)

    public static func &&(lhs: Formula, rhs: Formula) -> Formula {
        return .conjunction(lhs, rhs)
    }

    /// a → b
    indirect case implication(Formula, Formula)

    public static func =>(lhs: Formula, rhs: Formula) -> Formula {
        return .implication(lhs, rhs)
    }

    /// The negation normal form of the formula.
    public var nnf: Formula {
        switch self {
        case .proposition(_):
            return self
        case .negation(let a):
            switch a {
                case .proposition(_):
                    return self
                case .negation(let b):
                    return b.nnf
                case .disjunction(let b, let c):
                    return (!b).nnf && (!c).nnf
                case .conjunction(let b, let c):
                    return (!b).nnf || (!c).nnf
                case .implication(_):
                    return (!a.nnf).nnf
            }
        case .disjunction(let b, let c):
            return b.nnf || c.nnf
        case .conjunction(let b, let c):
            return b.nnf && c.nnf
        case .implication(let b, let c):
            return (!b).nnf || c.nnf
        }
    }

    /*
    *  /!\  Since we wrote the following code together with Terry it is allmost similar.
    *       We are both of us the authors and owners of this code and in no way one of us
    *       have been cheating on the other.
    */

    /// The disjunctive normal form of the formula.
    public var dnf: Formula {

        switch self {
            case .proposition(_): // a
                return self
            case .negation(_):  // !a
                return self

            case .disjunction(let a, let b): // (alpha v beta)
                switch a {

                    case .proposition(_): // a v beta
                        switch b {

                            case.proposition(_): // a v b
                                return self
                            case.negation(_): // a v !b
                                return self
                            case.disjunction(_): // a v (b1 v b2)
                                return (b || a).dnf
                            case.conjunction(_): // a v (b1 ^ b2)
                                return (b || a).dnf
                            default : // Non NNF form
                                fatalError("Unexpected value in DNF")
                        }

                    case .negation(_): // !a v beta
                        switch b {
                            case.proposition(_): // !a v b
                                return (self)
                            case.negation(_): // !a v !b
                                return (self)
                            case.disjunction(_): // !a v (b1 v b2)
                                return (b || a).dnf
                            case.conjunction(_): // !a v (b1 ^ b2)
                                return (b || a).dnf
                            default : // Non NNF form
                                fatalError("Unexpected value in DNF")
                        }

                    case .disjunction(_): // (a1 v a2) v beta
                        switch b {
                            case.proposition(_): // (a1 v a2) v b
                                return (a.dnf || b)
                            case.negation(_): // (a1 v a2) v !b
                                return (a.dnf || b)
                            case.disjunction(_): // (a1 v a2) v (b1 v b2)
                                return (a.dnf || b.dnf)
                            case.conjunction(_): // (a1 v a2) v (b1 ^ b2)
                                return (a.dnf || b.dnf)
                            default : // Non NNF form
                                fatalError("Unexpected value in DNF")
                        }

                    case .conjunction(_): // (a1 ^ a2) v beta (As it's already CNF, we don't need to use distributivity laws on a)
                        switch b {
                            case.proposition(_): // (a1 ^ a2) v b
                                return (a.dnf ||  b)
                            case.negation(_): // (a1 ^ a2) v !b
                                return (a.dnf ||  b)
                            case.disjunction(_): // (a1 ^ a2) v (b1 v b2)
                                return (a.dnf ||  b.dnf)
                            case.conjunction(_): // (a1 ^ a2) v (b1 ^ b2)
                                return (a.dnf ||  b.dnf)
                            default : // Non NNF form
                                fatalError("Unexpected value in DNF")
                        }

                    default : // Non NNF form
                        fatalError("Unexpected value in DNF")
                }

            case .conjunction(let a, let b): // alpha ^ beta
                switch a {
                    case .proposition(_): // a ^ beta
                        switch b {
                            case .proposition(_): // a ^ b
                                return self
                            case .negation(_): // a ^ !b
                                return self
                            case .disjunction(_): // a ^ (b1 v b2)
                                return (b && a).dnf
                            case .conjunction(_): // a ^ (b1 ^ b2)
                                return (b && a).dnf
                            default : // Non NNF Form
                                fatalError("Unexpected value in DNF")
                        }

                    case .negation(_): // !a ^ beta
                        switch b {
                            case .proposition(_): // !a ^ b
                                return (self)
                            case .negation(_): // !a ^ !b
                                return (self)
                            case .disjunction(_): // !a ^ (b1 v b2)
                                return (b && a).dnf
                            case .conjunction(_): // !a ^ (b1 ^ b2)
                                return (b && a).dnf
                            default : // Non NNF Form
                                fatalError("Unexpected value in DNF")
                        }

                    case .disjunction(let a1, let a2): // (a1 v a2) ^ (beta)
                        switch b {
                            case .proposition(_): // (a1 v a2) ^ b
                                return ((a1.dnf && b).dnf || (a2.dnf && b).dnf)
                            case .negation(_): // (a1 v a2) ^ !b
                                return ((a1.dnf && b).dnf || (a2.dnf && b).dnf)
                            case .disjunction(let b1, let b2): // (a1 v a2) ^ (b1 v b2)
                                return ((a1.dnf && b1.dnf).dnf || (a1.dnf && b2.dnf).dnf || (a2.dnf && b1.dnf).dnf || (a2.dnf && b2.dnf).dnf)
                            case .conjunction(let b1, let b2): // (a1 v a2) ^ (b1 ^ b2)
                                return ((a1.dnf && b1.dnf && b2.dnf)||(a2.dnf && b1.dnf && b2.dnf).dnf)
                            default : // Non NNF Form
                                fatalError("Unexpected value in DNF")
                        }

                    case .conjunction(let a1, let a2): // (a1 ^ a2) ^ beta
                        switch b {
                            case .proposition(_): // (a1 ^ a2) ^ b
                                return ((a1.dnf && a2.dnf).dnf && b)
                            case .negation(_): // (a1 ^ a2) ^ !b
                                return ((a1.dnf && a2.dnf).dnf && b)
                            case .disjunction(let b1, let b2): // (a1 ^ a2) ^ (b1 v b2)
                                return ((b1.dnf && a1.dnf && a2.dnf) || (b2.dnf && a1.dnf && a2.dnf))
                            case .conjunction(let b1, let b2): /// (a1 ^ a2) ^ (b1 ^ b2)
                                return ((a1.dnf && a2.dnf).dnf && (b1.dnf && b2.dnf).dnf)
                            default : // Non NNF Form
                                fatalError("Unexpected value in DNF")
                        }
                    default : // Non NNF Form
                        fatalError("Unexpected value in DNF")
                }
            default : // Non NNF Form
                fatalError("Unexpected value in DNF")
        }
        return self
    }

    /// The conjunctive normal form of the formula.
    public var cnf: Formula {

        switch self {
            case .proposition(_): // a
                return self

            case .negation(_): // !a
                return self

            case .disjunction(let a, let b): // alpha v beta
                switch a {
                    case .proposition(_): // a v beta
                        switch b {
                            case .proposition(_): // a v b
                                return self
                            case .negation(_): // a v !b
                                return self
                            case .disjunction(_): // a v (b1 v b2)
                                return (b || a).cnf
                            case .conjunction(_): // a v (b1 ^ b2)
                                return (b || a).cnf
                            default: // Non CNF Form
                                fatalError("Unexpected value in CNF")
                        }

                    case .negation(_):
                        switch b {
                            case .proposition(_): // !a v b
                                return self
                            case .negation(_): // !a v !b
                                return self
                            case .disjunction(_): // !a v (b1 v b2)
                                return (b || a).cnf
                            case .conjunction(_): // !a v (b1 ^ b2)
                                return (b || a).cnf
                            default: // Non CNF Form
                                fatalError("Unexpected value in CNF")
                        }

                    case .disjunction(let a1, let a2): // (a1 v a2) v beta
                        switch b {
                            case .proposition(_): // (a1 v a2) v b
                                return ((a1.cnf || a2.cnf).cnf || b)
                            case .negation(_): // (a1 v a2) v !b
                                return ((a1.cnf || a2.cnf).cnf || b)
                            case .disjunction(let b1, let b2): // (a1 v a2) v (b1 v b2)
                                return ((a1.cnf || a2.cnf).cnf || (b1.cnf || b2.cnf).cnf) // FIXME -> a.cnf || b.cnf
                            case .conjunction(let b1, let b2): // (a1 v a2) v (b1 ^ b2)
                                return ((b1.cnf || a1.cnf || a2.cnf) && (b2.cnf || a1.cnf || a2.cnf))
                            default: // Non CNF Form
                                fatalError("Unexpected value in CNF")
                        }

                    case .conjunction(let a1, let a2): // (a1 ^ a2) v beta
                        switch b {
                            case .proposition(_): // (a1 ^ a2) v b
                                return ((a1.cnf || b).cnf && (a2.cnf || b).cnf)
                            case .negation(_): // (a1 ^ a2) v !b
                                return ((a1.cnf || b).cnf && (a2.cnf || b).cnf)
                            case .disjunction(let b1, let b2): // (a1 ^ a2) v (b1 v b2)
                                return ((a1.cnf || b1.cnf || b2.cnf) && (a2.cnf || b1.cnf || b2.cnf))
                            case .conjunction(let b1, let b2): // (a1 ^ a2) v (b1 ^ b2)
                                return ((a1.cnf || b1.cnf).cnf && (a1.cnf || b2.cnf).cnf && (a2.cnf || b1.cnf).cnf && (a2.cnf || b2.cnf).cnf)
                            default: // Non CNF Form
                                fatalError("Unexpected value in CNF")
                        }

                    default: // Non CNF Form
                        fatalError("Unexpected value in CNF")
                }

            case .conjunction(let a, let b):
               switch a {
                    case .proposition(_): // a ^ beta
                        switch b {
                            case .proposition(_): // a ^ b
                                return self
                            case .negation(_): // a ^ !b
                                return self
                            case .disjunction(_): // a ^ (b1 v b2)
                                return (b && a).cnf
                            case .conjunction(_): // a ^ (b1 ^ b2)
                                return (b && a).cnf
                            default: // Non CNF Form
                                fatalError("Unexpected value in CNF")
                        }

                    case .negation(_):
                        switch b {
                            case .proposition(_): // !a ^ b
                                return self
                            case .negation(_): // !a ^ !b
                                return self
                            case .disjunction(_): // !a ^ (b1 v b2)
                                return (b && a).cnf
                            case .conjunction(_): // !a ^ (b1 ^ b2)
                                return (b && a).cnf
                            default: // Non CNF Form
                                fatalError("Unexpected value in CNF")
                        }

                    case .disjunction(_): // (a1 v a2) ^ beta
                        switch b {
                            case .proposition(_): // (a1 v a2) ^ b
                                return (a.cnf && b)
                            case .negation(_): // (a1 v a2) ^ !b
                                return (a.cnf && b)
                            case .disjunction(_): // (a1 v a2) ^ (b1 v b2)
                                return (a.cnf && b.cnf)
                            case .conjunction(_): // (a1 v a2) ^ (b1 ^ b2)
                                return (a.cnf && b.cnf)
                            default: // Non CNF Form
                                fatalError("Unexpected value in CNF")
                        }

                    case .conjunction(_): // (a1 ^ a2) ^ beta
                        switch b {
                            case .proposition(_): // (a1 ^ a2) ^ b
                                return (a.cnf && b)
                            case .negation(_): // (a1 ^ a2) ^ !b
                                return (a.cnf && b)
                            case .disjunction(_): // (a1 ^ a2) ^ (b1 v b2)
                                return (a.cnf && b.cnf)
                            case .conjunction(_): // (a1 ^ a2) ^ (b1 ^ b2)
                                return (a.cnf && b.cnf)
                            default: // Non CNF Form
                                fatalError("Unexpected value in CNF")
                        }

                    default: // Non CNF Form
                        fatalError("Unexpected value in CNF")
                }

            default:
                fatalError("Unexpected value in CNF")
        }

        return self
    }

    /// The propositions the formula is based on.
    ///
    ///     let f: Formula = (.proposition("p") || .proposition("q"))
    ///     let props = f.propositions
    ///     // 'props' == Set<Formula>([.proposition("p"), .proposition("q")])
    public var propositions: Set<Formula> {
        switch self {
        case .proposition(_):
            return [self]
        case .negation(let a):
            return a.propositions
        case .disjunction(let a, let b):
            return a.propositions.union(b.propositions)
        case .conjunction(let a, let b):
            return a.propositions.union(b.propositions)
        case .implication(let a, let b):
            return a.propositions.union(b.propositions)
        }
    }

    /// Evaluates the formula, with a given valuation of its propositions.
    ///
    ///     let f: Formula = (.proposition("p") || .proposition("q"))
    ///     let value = f.eval { (proposition) -> Bool in
    ///         switch proposition {
    ///         case "p": return true
    ///         case "q": return false
    ///         default : return false
    ///         }
    ///     })
    ///     // 'value' == true
    ///
    /// - Warning: The provided valuation should be defined for each proposition name the formula
    ///   contains. A call to `eval` might fail with an unrecoverable error otherwise.
    public func eval<T>(with valuation: (String) -> T) -> T where T: BooleanAlgebra {
        switch self {
        case .proposition(let p):
            return valuation(p)
        case .negation(let a):
            return !a.eval(with: valuation)
        case .disjunction(let a, let b):
            return a.eval(with: valuation) || b.eval(with: valuation)
        case .conjunction(let a, let b):
            return a.eval(with: valuation) && b.eval(with: valuation)
        case .implication(let a, let b):
            return !a.eval(with: valuation) || b.eval(with: valuation)
        }
    }

}

extension Formula: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self = .proposition(value)
    }

}

extension Formula: Hashable {

    public var hashValue: Int {
        return String(describing: self).hashValue
    }

    public static func ==(lhs: Formula, rhs: Formula) -> Bool {
        switch (lhs, rhs) {
        case (.proposition(let p), .proposition(let q)):
            return p == q
        case (.negation(let a), .negation(let b)):
            return a == b
        case (.disjunction(let a, let b), .disjunction(let c, let d)):
            return (a == c) && (b == d)
        case (.conjunction(let a, let b), .conjunction(let c, let d)):
            return (a == c) && (b == d)
        case (.implication(let a, let b), .implication(let c, let d)):
            return (a == c) && (b == d)
        default:
            return false
        }
    }

}

extension Formula: CustomStringConvertible {

    public var description: String {
        switch self {
        case .proposition(let p):
            return p
        case .negation(let a):
            return "¬\(a)"
        case .disjunction(let a, let b):
            return "(\(a) ∨ \(b))"
        case .conjunction(let a, let b):
            return "(\(a) ∧ \(b))"
        case .implication(let a, let b):
            return "(\(a) → \(b))"
        }
    }

}
