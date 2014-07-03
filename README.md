StemCellDBN
===========
April 2, 2014

EDISONv9

This is a customized version of the CRAN package called 'EDISON.'
It includes the following three main changes from the original package, which was published 2012-07-16 on CRAN by Frank Dondelinger and Sophie Lebre.

1) There is a pathway built in to take care of CP birth steps in the case where there is no room to add another CP due to the minimum size of time segments. 

2) A bug is corrected in the function make_structure_move so that the main loop in that function goes through all time segments, thus allowing edge addition/removal on all segment networks.

3) Added an option to impose a hard constraint on edges in the last time segment of the model. In other words, the edges you specify will be included in the network model corresponding to the final time segment. 

Please search for the phrase "NEW to v9" which is included in each comment explaining the changes to the code.

To run this software, install the CRAN package 'EDISON' and use the R command 'source' to load in all the .R function files from this folder into the R session. Please note that this version of EDISON is not optimized for information sharing. 

Author: Megha Padi





