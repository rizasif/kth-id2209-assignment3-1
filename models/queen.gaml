/**
* Name: queen
* Author: rizas
* Description:
* Tags: Tag1, Tag2, TagN
*/

model queen

global {
    int NB_GRID_NEIGHBORS <- 8;
    int NB_QUEENS <- 10;
    
    init{
        create Queen number: NB_QUEENS;
    }
    
    list<ChessBoardCell> ALL_CELLS;
    list<Queen> ALL_QUEENS;
    
    bool isCalculating <- false;
    
}

species Queen{
    ChessBoardCell myCell <- one_of (ChessBoardCell);
    list<list<int>> occupancy_grid;
    
    init {
        //Assign a free cell
        loop cell over: myCell.neighbours{
            if cell.queen = nil{
                myCell <- cell;
                break;        
            }
        }
        location <- myCell.location;
        myCell.queen <- self;
        
        add self to: ALL_QUEENS;
        
        //Initialize the occupancy grid with zeros
        do refreshOccupancyGrid;
    }
    
    //ACTIONS
    action refreshOccupancyGrid{
        self.occupancy_grid <- [];
        loop m from:0 to: NB_QUEENS-1{
            list<int> mList;
            loop n from:0 to: NB_QUEENS-1{
                add 0 to: mList;    
            }
            add mList to: occupancy_grid;
        }
    }
    
    action calculateOccupancyGrid{
        do refreshOccupancyGrid;
        
        // Identify all occupied cells
        loop cell over: ALL_CELLS{
            if cell.queen != nil and cell.queen != self{
                self.occupancy_grid[cell.grid_x][cell.grid_y] <- 1000;
            }
        }
        
        // Evaluate free cells
            loop cell over: ALL_CELLS{
                int m <- cell.grid_x;
                int n <- cell.grid_y;
                if self.occupancy_grid[int(m)][int(n)] = 1000{
                    loop i from: 1 to:NB_QUEENS{
                        
                        // Up
                        int mi <- int(m) + i;
                        if mi < NB_QUEENS{
//                            write "Adding occupied at: " + mi + ", " + n;
                            self.occupancy_grid[mi][n] <- self.occupancy_grid[mi][n] + 1;
                        }
                        
                        //Down
                        int n_mi <- int(m) - i;
                        if n_mi > -1{
//                            write "Adding occupied at: " + n_mi + ", " + n;
                            self.occupancy_grid[n_mi][n] <- self.occupancy_grid[n_mi][n] + 1;
                        }
                        
                        // Right
                        int ni <- int(n) + i;
                        if ni < NB_QUEENS{
//                            write "Adding occupied at: " + m + ", " + ni;
                            self.occupancy_grid[m][ni] <- self.occupancy_grid[m][ni] + 1;
                        }
                        
                        //Left
                        int n_ni <- int(n) - i;
                        if n_ni > -1{
//                            write "Adding occupied at: " + m + ", " + n_ni;
                            self.occupancy_grid[m][n_ni] <- self.occupancy_grid[m][n_ni] + 1;
                        }
                        
                        //top right diagonal
                        if mi < NB_QUEENS and ni < NB_QUEENS{
//                            write "Adding occupied at: " + mi + ", " + ni;
                            self.occupancy_grid[mi][ni] <- self.occupancy_grid[mi][ni] + 1;
                        }
                        
                        //bottom right diagonal
                        if n_mi > -1 and ni < NB_QUEENS{
//                            write "Adding occupied at: " + n_mi + ", " + ni;
                            self.occupancy_grid[n_mi][ni] <- self.occupancy_grid[n_mi][ni] + 1;
                        }
                        
                        //top left diagonal
                        if mi < NB_QUEENS and n_ni > -1{
//                            write "Adding occupied at: " + mi + ", " + n_ni;
                            self.occupancy_grid[mi][n_ni] <- self.occupancy_grid[mi][n_ni] + 1;
                        }
                        
                        //bottom left diagonal
                        if n_mi > -1 and n_ni > -1{
//                            write "Adding occupied at: " + n_mi + ", " + n_ni;
                            self.occupancy_grid[n_mi][n_ni] <- self.occupancy_grid[n_mi][n_ni] + 1;
                        }
                    }
                }
            }
    }
    
    list<point> availableCells(int val) {
        list<point> Checks;
        loop cell over: ALL_CELLS{
            int m <- cell.grid_x;
            int n <- cell.grid_y;
            if self.occupancy_grid[int(m)][int(n)] = val and !(m = myCell.grid_x and n = myCell.grid_y){
                if myCell.grid_x = int(m) {
                    add {int(m),int(n)} to: Checks;    
                }
                else if myCell.grid_y = int(n) {
                    add {int(m),int(n)} to: Checks;    
                }
                else{
                    int diff_x <- abs(int(m) - myCell.grid_x);
                    int diff_y <- abs(int(n) - myCell.grid_y);
                    
                    if diff_x = diff_y{
                        add {int(m),int(n)} to: Checks;    
                    }    
                }                            
            }
        }
        return Checks;
    }
    
//    Queen findQueenInSight(int x){
//    	list<Queen> allSightQueens;
//    	loop q over: ALL_QUEENS{
//    		if q.location != self.location{
//    			ask q{
//	    			if myself.myCell.grid_x = self.myCell.grid_x {
//	                    add self to: allSightQueens;
//	                }
//	                else if myself.myCell.grid_y = self.myCell.grid_y {
//	                    add self to: allSightQueens;        
//	                }
//	                else{
//	                    int diff_x <- abs(myself.myCell.grid_x - self.myCell.grid_x);
//	                    int diff_y <- abs(myself.myCell.grid_y - self.myCell.grid_y);
//	                    
//	                    if diff_x = diff_y{
//	                        add self to: allSightQueens;    
//	                    }    
//	                }
//    			}
//    		}
//    	}
//    	if length(allSightQueens) > 0{
//    		Queen sight <- allSightQueens[rnd(0, length(allSightQueens)-1)];
//    		return sight;	
//    	} else{
//    		return nil;
//    	}
//    }
    
    Queen findQueenInSightbyLocation(int x){
    	list<Queen> allSightQueens;
    	
    	loop cell over: ALL_CELLS{
            int m <- cell.grid_x;
            int n <- cell.grid_y;
            
            if self.occupancy_grid[m][n] > 999{
            	if m = self.myCell.grid_x {
            		add cell.queen to: allSightQueens;
            	}
            	else if n = self.myCell.grid_y {
            		add cell.queen to: allSightQueens;
            	}
            	else{
            		int diff_x <- abs(m - self.myCell.grid_x);
            		int diff_y <- abs(n - self.myCell.grid_y);
            		if diff_x = diff_y{
            			add cell.queen to: allSightQueens;
            		}
            	}
            }
        }
    	
    	if length(allSightQueens) > 0{
    		Queen sight <- allSightQueens[rnd(0, length(allSightQueens)-1)];
    		return sight;	
    	} else{
    		return nil;
    	}
    }
    
    action needToMove{
    	do calculateOccupancyGrid();
	    if self.occupancy_grid[myCell.grid_x][myCell.grid_y] != 0{
	    	list<point> goodChecks <- availableCells(0);
	    	if length(goodChecks) > 0 {
	    		point goodPoint <- goodChecks[rnd(0,length(goodChecks)-1)];
	    		loop c over: ALL_CELLS {
	    			if c.grid_x = goodPoint.x and c.grid_y = goodPoint.y and c.queen = nil{
	    				myCell.queen <- nil;
	    				myCell <- c;
	    				location <- c.location;
	    				myCell.queen <- self;
	    				
	    				write "Options: " + goodChecks;
	    				write "Moved to: " + c.grid_x + ", " + c.grid_y;
	    				write "Utility: " + self.occupancy_grid[c.grid_x][c.grid_y];
	    				write "Grid: " + self.occupancy_grid;
	    				
	    				break;
	    			}
	    		}
	    	}
	    	else{
	    		write "I cannot move from: " + self.myCell.grid_x + ", " + self.myCell.grid_y;
	    		// Talk to someone else for moving
	    		Queen sight <- findQueenInSightbyLocation(0);
	    		if sight != nil{
	    			ChessBoardCell sightCell;
	    			ask sight{
	    				write "Iam: " + myself.myCell.grid_x + ", " + myself.myCell.grid_y + " Asking: " + self.myCell.grid_x + ", " + self.myCell.grid_y;
	    				sightCell <- self.myCell;
	    			}
	    			ChessBoardCell target;
	    			float distance <- 1000.0;
	    			loop s over:sightCell.neighbours{
	    				float dist <- myCell.location distance_to s.location;
	    				if dist < distance and dist!=0 and s.queen = nil{
	    					distance <- dist;
	    					target <- s;
	    				}
	    			}
	    			write "New Location: " + target.grid_x + ", " + target.grid_y;
	    			myCell.queen <- nil;
	    			myCell <- target;
	    			location <- target.location;
	    			myCell.queen <- self;
	    		}
	    	}
	    }
	}
    
    //REFLEXES
    reflex amIsafe when: !isCalculating{
    	isCalculating <- true;
    	do needToMove;
    	isCalculating <- false;
    }
    
    
    aspect base {
        draw circle(1.0) color: #green ;
    }
}

grid ChessBoardCell width: NB_QUEENS height: NB_QUEENS neighbors: NB_GRID_NEIGHBORS {
    list<ChessBoardCell> neighbours  <- (self neighbors_at 2);
    Queen queen <- nil;
    
    init{
        add self to: ALL_CELLS;
    }
}

experiment ChessBoard type: gui {
    output {
        display main_display {
            grid ChessBoardCell lines: #black ;
            species Queen aspect: base ;
        }
    }
}


