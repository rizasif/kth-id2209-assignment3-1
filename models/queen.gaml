/**
* Name: queen
* Author: rizas
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model queen

global {
	int NB_GRID_NEIGHBORS <- 8;
	int NB_QUEENS <- 4;
	
	init{
		create Queen number: NB_QUEENS;
	}
	
	list<ChessBoardCell> ALL_CELLS;
	
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
		
		//Initialize the occupancy grid with zeros
		do refreshOccupancyGrid;
	}
	
	//ACTIONS
	action refreshOccupancyGrid{
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
		loop m over: length(self.occupancy_grid)-1{
			loop n over: length(self.occupancy_grid[0])-1{
				if self.occupancy_grid[int(m)][int(n)] = 1000{
					loop i from: 1 to:NB_QUEENS{
						
						// Up
						int mi <- int(m) + i;
						if mi < NB_QUEENS{
							self.occupancy_grid[mi][n] <- self.occupancy_grid[mi][n] + 1; 
						}
						
						//Down
						int n_mi <- int(m) - i;
						if n_mi > -1{
							self.occupancy_grid[n_mi][n] <- self.occupancy_grid[n_mi][n] + 1; 
						}
						
						// Right
						int ni <- int(n) + i;
						if ni < NB_QUEENS{
							self.occupancy_grid[m][ni] <- self.occupancy_grid[m][ni] + 1; 
						}
						
						//Left
						int n_ni <- int(n) - i;
						if n_ni > -1{
							self.occupancy_grid[m][n_ni] <- self.occupancy_grid[m][n_ni] + 1; 
						}
						
						//top right diagonal
						if mi < NB_QUEENS and ni < NB_QUEENS{
							self.occupancy_grid[mi][ni] <- self.occupancy_grid[mi][ni] + 1;
						}
						
						//bottom right diagonal
						if n_mi > -1 and ni < NB_QUEENS{
							self.occupancy_grid[n_mi][ni] <- self.occupancy_grid[n_mi][ni] + 1;
						}
						
						//top left diagonal
						if mi < NB_QUEENS and n_ni > -1{
							self.occupancy_grid[mi][n_ni] <- self.occupancy_grid[mi][n_ni] + 1;
						}
						
						//bottom left diagonal
						if n_mi > -1 and n_ni > -1{
							self.occupancy_grid[n_mi][n_ni] <- self.occupancy_grid[n_mi][n_ni] + 1;
						}
					}
				}
			}
		}
	}
	
	//REFLEXES
	
	
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