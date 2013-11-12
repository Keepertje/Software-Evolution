module Dupl2

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import LOC;
import Prelude;
import util::Math;

//:set profiling true;

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
			println("Compare <file1> with <file2>");			
			bool SameFile = file1 == file2;
			map[str testa, bool boola] testMap = ();
			list[str] lines2 = readInFiles[file2];
			int file2Size = size(lines2);
			int i = 0;int j = 0;int tempi;int tempj;
			while(i < file1Size){while(j < file2Size){
				if("<i> <j>" in testMap) continue;
				tempi=i;tempj=j;
				if(lines1[i] == lines2[j] && !(SameFile && i>=j)){
					while(lines1[tempi] == lines2[tempj]){
						tempi=tempi+1;tempj=tempj+1;						
						if(tempi >= file1Size || tempj >= file2Size) break;	
					}
					if(tempi - i >= 6){
						//Mark as false
						for(int k <- [0..(tempi-i)]){
							testMap = testMap + ("<i> <j>": true);
						}
						duplicatedLines = duplicatedLines + ((tempi - i)*2);	
							
					}
									
				}
			j = j+1;
			}
			i = i + 1;
			}				
			count = count +1;
			if(count % 100 == 0){
				percentage = (count*1.0)/totalComparison;
				println("Percentage completed <round(percentage*100)>");
				println("DupCount = <duplicatedLines>");
			}

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