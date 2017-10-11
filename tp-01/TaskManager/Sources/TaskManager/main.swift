import TaskManagerLib

let taskManager = createTaskManager()
let correctTaskManager = createCorrectTaskManager()


func base(){
  guard let create = taskManager.transitions.first(where: {$0.name == "create"}) else{
    fatalError("unable to import transition")
  }
  guard let spawn = taskManager.transitions.first(where: {$0.name == "spawn"}) else{
    fatalError("unable to import transition")
  }
  guard let exec = taskManager.transitions.first(where: {$0.name == "exec"})else{
    fatalError("unable to import transition")
  }
  guard let success = taskManager.transitions.first(where: {$0.name == "success"}) else {
    fatalError("unable to import transition")
  }
  guard let fail = taskManager.transitions.first(where: {$0.name == "fail"}) else {
    fatalError("unable to import transition")
  }

  guard let taskPool = taskManager.places.first(where: {$0.name == "taskPool"}) else {
      fatalError("unable to import place")
  }
  guard let inProgress = taskManager.places.first(where: {$0.name == "inProgress"}) else {
    fatalError("unable to import place")
  }
  guard let processPool = taskManager.places.first(where: {$0.name == "processPool"}) else {
    fatalError("unable to import place")
  }

  guard let mark1 = create.fire(from: [taskPool: 0, processPool: 0, inProgress: 0]) else{fatalError("unable to fire transition")}
  print("m1 \(mark1)")
  guard let mark2 = spawn.fire(from: mark1) else{fatalError("unable to fire transition")}
  print("m2 \(mark2)")
  guard let mark3 = spawn.fire(from: mark2) else{fatalError("unable to fire transition")}
  print("m3 \(mark3)")
  guard let mark4 = exec.fire(from: mark3) else{fatalError("unable to fire transition")}
  print("m4 \(mark4)")
  guard let mark5 = exec.fire(from: mark4) else{fatalError("unable to fire transition")}
  print("m5 \(mark5)")
  guard let mark6 = success.fire(from: mark5) else{fatalError("unable to fire transition")}
  print("m6 \(mark6)")
  guard let mark7 = fail.fire(from: mark6) else{fatalError("unable to fire transition")}
  print("m7 \(mark7)")
}

func correct(){
  guard let create = correctTaskManager.transitions.first(where: {$0.name == "create"}) else{
    fatalError("unable to import transition")
  }
  guard let spawn = correctTaskManager.transitions.first(where: {$0.name == "spawn"}) else{
    fatalError("unable to import transition")
  }
  guard let exec = correctTaskManager.transitions.first(where: {$0.name == "exec"})else{
    fatalError("unable to import transition")
  }
  guard let success = correctTaskManager.transitions.first(where: {$0.name == "success"}) else {
    fatalError("unable to import transition")
  }
  guard let fail = correctTaskManager.transitions.first(where: {$0.name == "fail"}) else {
    fatalError("unable to import transition")
  }

  guard let taskPool = correctTaskManager.places.first(where: {$0.name == "taskPool"}) else {
      fatalError("unable to import place")
  }
  guard let inProgress = correctTaskManager.places.first(where: {$0.name == "inProgress"}) else {
    fatalError("unable to import place")
  }
  guard let processPool = correctTaskManager.places.first(where: {$0.name == "processPool"}) else {
    fatalError("unable to import place")
  }
  guard let taskChecker = correctTaskManager.places.first(where: {$0.name == "taskChecker"}) else {
      fatalError("unable to import place")
  }

  guard let mark1 = create.fire(from: [taskPool: 0, processPool: 0, inProgress: 0, taskChecker: 0]) else{fatalError("unable to fire transition")}
  print("m1 \(mark1)")
  guard let mark2 = spawn.fire(from: mark1) else{fatalError("unable to fire transition")}
  print("m2 \(mark2)")
  guard let mark3 = spawn.fire(from: mark2) else{fatalError("unable to fire transition")}
  print("m3 \(mark3)")
  guard let mark4 = exec.fire(from: mark3) else{fatalError("unable to fire transition")}
  print("m4 \(mark4)")
  guard let mark5 = exec.fire(from: mark4) else{fatalError("unable to fire transition")}
  print("m5 \(mark5)")
  guard let mark6 = success.fire(from: mark5) else{fatalError("unable to fire transition")}
  print("m6 \(mark6)")
  guard let mark7 = fail.fire(from: mark6) else{fatalError("unable to fire transition")}
  print("m7 \(mark7)")
}

base()
correct()
