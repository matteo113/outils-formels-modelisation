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

  print("(CREATE) -->")
  guard let mark1 = create.fire(from: [taskPool: 0, processPool: 0, inProgress: 0]) else{print("unable to fire transition"); return}
  print("m1 = \(mark1)")
  print()
  print("(SPAWN) -->")
  guard let mark2 = spawn.fire(from: mark1) else{print("unable to fire transition"); return}
  print("m2 = \(mark2)")
  print()
  print("(SPAWN) -->")
  guard let mark3 = spawn.fire(from: mark2) else{print("unable to fire transition"); return}
  print("m3 = \(mark3)")
  print()
  print("(EXEC) -->")
  guard let mark4 = exec.fire(from: mark3) else{print("unable to fire transition"); return}
  print("m4 = \(mark4)")
  print("As we can see here it is possible to fire EXEC a second time with the same task")
  print()
  print("(EXEC) -->")
  guard let mark5 = exec.fire(from: mark4) else{print("unable to fire transition"); return}
  print("m5 = \(mark5)")
  print("Yet we have two times the same task inProgress but only one token in taskPool :(")
  print()
  print("(SUCCESS) -->")
  guard let mark6 = success.fire(from: mark5) else{print("unable to fire transition"); return}
  print("m6 = \(mark6)")
  print("""
  The poor lonely token is yet stuck. It's only way to escape this eternal trap is to fail
  wich would be really sad for him because nobody likes to fail.
  """)
  print()
  print("(FAIL) -->")
  guard let mark7 = fail.fire(from: mark6) else{print("unable to fire transition"); return}
  print("m7 = \(mark7)")
}

func correct(error: Bool){
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

  print("(CREATE) -->")
  guard let mark1 = create.fire(from: [taskPool: 0, processPool: 0, inProgress: 0, taskChecker: 0]) else{print("unable to fire transition"); return}
  print("m1 \(mark1)")
  print()
  print("(SPAWN) -->")
  guard let mark2 = spawn.fire(from: mark1) else{print("unable to fire transition"); return}
  print("m2 \(mark2)")
  print()
  print("(SPAWN) -->")
  guard let mark3 = spawn.fire(from: mark2) else{print("unable to fire transition"); return}
  print("m3 \(mark3)")
  print()
  print("(EXEC) -->")
  guard let mark4 = exec.fire(from: mark3) else{print("unable to fire transition"); return}
  print("m4 \(mark4)")
  print()
  if error {
    print("(EXEC) -->")
    guard let mark5 = exec.fire(from: mark4) else{print("unable to fire transition"); return}
    print("m5 \(mark5)")
  }

  print("(SUCCESS) -->")
  guard let mark5 = success.fire(from: mark4) else{print("unable to fire transition"); return}
  print("m5 \(mark5)")
}

base()
print("""

**************************************************************************************************************************
                .88888888:.
               88888888.88888.
             .8888888888888888.
             888888888888888888
             88' _`88'_  `88888
             88 88 88 88  88888
             88_88_::_88_:88888
             88:::,::,:::::8888
             88`:::::::::'`8888
            .88  `::::'    8:88.
           8888            `8:888.
         .8888'             `888888.
        .8888:..  .::.  ...:'8888888:.
       .8888.'     :'     `'::`88:88888
      .8888        '         `.888:8888.
     888:8         .           888:88888
   .888:88        .:           888:88888:
   8888888.       ::           88:888888
   `.::.888.      ::          .88888888
  .::::::.888.    ::         :::`8888'.:.
 ::::::::::.888   '         .::::::::::::
 ::::::::::::.8    '      .:8::::::::::::.
.::::::::::::::.        .:888:::::::::::::
:::::::::::::::88:.__..:88888:::::::::::'
 `'.:::::::::::88888888888.88:::::::::'
     `':::_:' -- '' -'-' `':_::::'`
**************************************************************************************************************************

""")
correct(error: true)

print("""


as we can se if we try the same pattern as previously it is not possible to fire EXEC with the same task a second time.

**************************************************************************************************************************
**************************************************************************************************************************

Yet if we try the corect pattern it will perform as wanted.


""")

correct(error: false)
