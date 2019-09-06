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
      result
        goto Blue1
world Blue1
  scene Blue1
    choice
      result
        goto Finish
    choice
      result
        goto Red1
world Finish
  scene Finish
