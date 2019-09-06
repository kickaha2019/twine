world Start
  scene Start
    choice
      result
        goto Red1
    choice
      result
        goto Red2
world Red1
  scene Red1
    choice
      result
        goto Blue1
    choice
      result
        goto Blue2
world Red2
  scene Red2
    choice
      result
        goto Blue1
    choice
      result
        goto Blue2
    choice
      result
        goto Finish
world Blue1
  scene Blue1
    choice
      result
        goto Red1
    choice
      result
        goto Red2
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
        goto Red2
    choice
      result
        goto Finish
world Finish
  scene Finish
