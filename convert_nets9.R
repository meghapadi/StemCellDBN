convert_nets9 <-
function(Ball, Eall, target) {
  B_nets = list()
  E = Eall[[target]]
  
  # NEW to v9:
  # networks are listed by segment for this particular target, instead of for all global segments.
  # this makes it consistent with the make_structure_move loop.
  
  # Initialise segment list
  for(segment in 1:(length(E)-1)) {
    B_nets[[segment]] = matrix(0, dim(Ball[[1]])[2], length(Ball))
  }
  
  # Build up segment list
  for(segment in 1:(length(E)-1)) {
        B_nets[[segment]][,target] = Ball[[target]][segment,] 
  }
  
  return(list(B_nets=B_nets))
}

