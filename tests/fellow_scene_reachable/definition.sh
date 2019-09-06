world Start
  scene Start
    choice
      result
        goto Red1
world Red1
  scene Red1
    choice
      result
        goto Finish
  scene Red2
    choice
      result
        goto Red1
    choice
      result
        goto Finish
world Finish
  scene Finish
