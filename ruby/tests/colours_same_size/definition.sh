world Start
  scene Start
    choice
      result
        goto Red1
world Red1
  scene Red1
    choice
      result
        goto Blue1
    choice
      result
        goto Blue2
world Blue1
  scene Blue1
    choice
      result
        goto Red1
    choice
      result
        goto Finish
world Blue2
  scene Blue2
    choice
      result
        goto Red1
    choice
      result
        goto Finish
world Finish
  scene Finish
