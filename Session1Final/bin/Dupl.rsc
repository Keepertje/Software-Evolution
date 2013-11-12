module Dupl

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import LOC;
import Prelude;
alias matrix = list[list[bool]];

public int CodeDuplication(M3 project)
{
	int duplicatedLines = 0;
	int count = 0;
	//Step 1: Make file pairs
	list[loc] projFiles = toList(filesWithoutUnit(project));
	list[tuple[loc first,list[loc] sec]] PairFiles = [];
	int totalComparison = fac3(size(projFiles));
	real percentage = 0.0;
	//Read in Files
	map[loc location, list[str] file] readInFiles = ();
	for(file <- projFiles){
		println("Read in <file>");
		readInFiles = readInFiles + (file:removeComments(readFile(file),false));
	}
	println("done reading");
	//Loop over all File Pairs
	for( file1 <- projFiles){
	
		list[loc] locList = [ filess | filess <- projFiles, indexOf(projFiles,filess) >= indexOf(projFiles,file1)];
		//Step 2.1 Read The First File
		list[str] lines1 = readInFiles[file1];
		int file1Size = size(lines1);

		for(loc file2 <- locList){
			//Step 2.2: Read The Second File
			println("Compare <file1> with <file2>");			
			bool SameFile = file1 == file2;
			list[str] lines2 = readInFiles[file2];
			int file2Size = size(lines2);
		
			//Step 3: Initialize Matrix
			matrix boolMat = [];
			for(int i <- [0..file1Size], int j <- [0..file2Size]){
		 		if(j == 0) boolMat = boolMat + [[false]];
		 		else boolMat[i] = boolMat[i] + [false];
			}
			//Step 4: Perform String Comparison and set matrix
			for(int i <- [0..file1Size], int j <- [0..file2Size]){
				if(lines1[i] == lines2[j]){
					if(!(SameFile && i>=j)){
						boolMat[i][j] = true;
					}
				}
			}
			//println("===================================");
			//printMatrix(boolMat);
			//Step 5: Walk through the Matrix
			int tempi;
			int tempj;
			for(int i <- [0..file1Size], int j <- [0..file2Size]){
				tempi = i;tempj=j;
				while(boolMat[tempi][tempj]){
					tempi=tempi+1;tempj=tempj+1;
					if(tempi >= file1Size || tempj >= file2Size) break;
				}
				
				if(tempi - i >= 5){
					duplicatedLines = duplicatedLines + ((tempi - i)*2);
					//Set to false again so the lines are not matched anymore
					tempi = i;tempj=j;
					while(boolMat[tempi][tempj]){
						boolMat[tempi][tempj]= false;tempi=tempi+1;tempj=tempj+1;
						if(tempi >= file1Size || tempj >= file2Size) break;
					}				
				}
			}
			count = count +1;
			percentage = (count*1.0)/totalComparison;
			println("Percentage completed <percentage>");
			println("DupCount = <duplicatedLines>");
		}
	}
	return duplicatedLines;

}
//Help for Debugging
public int fac3(int N)  { 
  if (N == 0) 
    return 1;
  return N * fac3(N - 1);
}
public void printMatrix(matrix a)
{
	for(b <- a) {
		for(c <- b){
			if(c)print("* ");
			else print(". ");
			};
		println("");
		}
}