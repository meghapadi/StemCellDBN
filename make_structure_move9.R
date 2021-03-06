make_structure_move9 <-
function(x, y, S, B, Sig2, q,  
                                qmax, network.info, method, Mphase, E, HYPERvar, hard.const) {
  # Makes a network structure move for one edge in one of the segments.
  #
  # Args:
  #   u: Random value between 0 and 1
  #   x: Prediction data
  #   y: Target data
  #   S: Structure of the current segment
  #   Sig2: Variance for the current segment
  #   delta2: Current value of delta2 parameter.
  #   q: Number of nodes
  #   v0: Hyperparameter
  #   gamma0: Hyperparameter
  #   qmax: Maximum number of parents.
  #   lambda: Parameter for the poisson distribution on the number of parents
  #   network.info: The network structures and associated information.
  #             network.info$nets       - Structure of all segments 
  #             network.info$betas      - Beta parameters for all segments
  #             network.info$segment    - Segment being changed
  #             network.info$target     - Target node whose edge is being changed
  #             network.info$parent     - Parent being changed
  #             network.info$self.loops - Indicator variable whether self-loops
  #                                       are allowed
  #   method: The information sharing method used. Currently supports "poisson"
  #           (no information sharing) and "exp_soft" (sequential exponential 
  #           information sharing with soft coupling of nodes)
  # Returns:
  #   Structure describing the result of the new move.

  ### Assignment of hyperparameters variables used here ###
  c = HYPERvar$c
  alphalbd = HYPERvar$alphalbd
  betalbd = HYPERvar$betalbd
  alphad2 = HYPERvar$alphad2
  betad2 = HYPERvar$betad2
  v0 = HYPERvar$v0
  gamma0 = HYPERvar$gamma0
  ### End assignment ###

  # Boolean indicating whether the move is accepted or not 
  # (=1 if accepted, 0 otherwise, default=0)
  accept = 0

  ## New edges vector, to be returned at the end of the function
  newS = S

  posPhase = sample(1:(length(E) - 1), 1)
  edge = sample(1:q, 1)
   
  # Current segment and edge
  network.info$segment = posPhase
  network.info$parent  = edge

  S.proposal = matrix(0, dim(B)[1], dim(B)[2])
  delta2 = array(0, length(E) - 1)
  lambda = array(0, length(E) - 1)
 
  likelihood.ratio = 1
  
  move = 4
  
  # NEW to v9:
  # define the parents for the hard constraint
  
  if (!is.null(hard.const)) hard.par = as.numeric(hard.const[hard.const[,2]==network.info$target,1]) else
  hard.par <- 0
 

  for(segment in 1:(length(E)-1)) {
  	
    seg.start = E[segment]
    seg.end   = E[segment + 1] 

    y.temp = y[ Mphase[seg.start]:(Mphase[seg.end]-1) ] 
    x.temp = x[ Mphase[seg.start]:(Mphase[seg.end]-1), ]
      
    B.temp = B[segment,]
    S.temp = (abs(B.temp) > 0) * 1
    
    Sig2.temp = Sig2[segment]

    k = sum(S.temp)-1

    ## Updating hyperparameters
    delta2[segment] = rinvgamma(1, shape=k + alphad2, 
                                scale=betad2 + B.temp[which(S.temp==1)] %*% 
             t(x.temp[,which(S.temp==1)]) %*% x.temp[,which(S.temp==1)] %*% 
             B.temp[which(S.temp==1)] / (2*Sig2.temp) )
  
    if(method == 'poisson') {
      lambda[segment] = rgamma(1, shape=k + alphalbd, rate=1 + betalbd)
    }
      
    ## Compute the projection matrix with the current edge ("Pxl")
    Pxl = computePx(length(y.temp), x.temp[,which(S.temp == 1)], 
                      delta2[segment])
       
    S.proposal.seg = S.temp
    
    # Half the time, swap the edge state
    
    # NEW to v9:
    # Do not flip edge if it is part of hard constraint and we are dealing with the last segment
    
    if ((segment!=(length(E)-1)) || (length(intersect(edge,hard.par))==0))
    {
    if(runif(1, 0, 1) > 0.5) {
      S.proposal.seg[edge] = !S.temp[edge]*1
      network.info$new.nets[[segment]][edge, network.info$target] =  ## REMOVE THIS LINE
       !network.info$new.nets[[segment]][edge, network.info$target]*1
      if(S.proposal.seg[edge] == 0) {
        dir = -1
      } else {
        dir = 1
      }
    } else dir=0 } else {
      dir = 0
    }
    
    
    S.proposal[segment,] = S.proposal.seg

    
    

    ## Compute the projection matrix with a modified edge ("Pxl modified")
    Pxlm = computePx(length(y.temp), x.temp[,which(S.proposal.seg == 1)], delta2[segment])
     
    likelihood.temp = CalculateLikelihoodRatio(gamma0, y.temp, Pxlm, Pxl, v0, 
                                                 delta2[segment], dir)

 
    # Ratio of (segment) data likelihoods
    likelihood.ratio = likelihood.ratio * likelihood.temp
 
  }
  
    
  # Ratio of proposal probabilities (1 because the move is symmetric)
  proposal.ratio = 1
    
  # Ratio of network structure priors
  prior.ratio = CalculatePriorRatio(method, q, lambda, network.info);
    
  ## Compute birth ratio
  r.indiv = proposal.ratio * prior.ratio * likelihood.ratio
    
  ## Sample u 
  u = runif(1,0,1)
 
  if(u <= min(1,r.indiv) && AcceptableMove(S.proposal, qmax, 
                              network.info$self.loops, network.info$target)) {
    accept = 1
    newS = S.proposal
  }

  ## Updating coefficients 
  newB = matrix(0, dim(B)[1], dim(B)[2])
  
  for(segment in 1:(length(E) - 1)) {
     y.temp = y[ Mphase[seg.start]:(Mphase[seg.end]-1) ] 
     x.temp = x[ Mphase[seg.start]:(Mphase[seg.end]-1), ]
      
    if(sum(newS) > 0){
      newB[segment, which(newS[segment,] == 1)] = 
        sampleBxy(x.temp[, which(newS[segment,]==1)], y.temp, Sig2[segment], 
                  delta2[segment])
    }
  }
  
 
  ##  Return all variables
  return(list( newS=newS, newB=newB, move=move, accept=accept))
}

