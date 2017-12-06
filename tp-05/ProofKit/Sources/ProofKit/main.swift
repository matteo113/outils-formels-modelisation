import ProofKitLib

let a: Formula = "a"
let b: Formula = "b"
let c: Formula = "c"
let d: Formula = "d"

let f = !(a && b)
let f1 = a&&(b||c)
let f2 = (!((a || d)||b))&&(b||(!c))

print("Original : \(f)")
print("NNF : \(f.nnf)")
print("DNF : \(f.nnf.dnf)")
print("CNF : \(f.nnf.cnf)")
print("\n")

print("Original : \(f1)")
print("NNF : \(f1.nnf)")
print("DNF : \(f1.nnf.dnf)")
print("CNF : \(f1.nnf.cnf)")
print("\n")

print("Original : \(f2)")
print("NNF : \(f2.nnf)")
print("DNF : \(f2.nnf.dnf)")
print("CNF : \(f2.nnf.cnf)")
print("\n")
