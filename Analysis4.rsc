module Analysis4

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import IO;
import List;
import String;
import Set;
import Boolean;

alias matrix = list[list[bool]];

M3 m3project1 = createM3FromEclipseProject(|project://Test|);

int countMethods(M3 project)
{
	return size(methods(project));
}

void AnalyzeMethods()
{
	set[Declaration] ast = createAstsFromEclipseProject(|project://Test|,true);
	visit(ast){
		case m:method(v1,v2,v3,v4,v5) :{
			println("name = <v2>");
			println("src = <v5 @ src>"); 
			int LOCS = countLOC(v5 @ src);
			int CC = codeComplexity(v5);
			println("LOC = <LOCS>");
			println("CC = <CC>");			
		}
	}	
}
/* 
	Code Duplication
*/

public int CodeDuplication(M3 project)
{
	int duplicatedLines = 0;
	//Step 1: Make file pairs
	list[loc] projFiles = toList(files(project));
	list[tuple[loc first,list[loc] sec]] PairFiles = [];
	
	for(file <- projFiles){
		int index = indexOf(projFiles,file);
		list[loc] locList = [ filess | filess <- projFiles, indexOf(projFiles,filess) >= index];
		PairFiles = PairFiles + <file,locList>; 
	}
	//Loop over all File Pairs
	for( file1Tuple <- PairFiles){
	
		//Step 2.1 Read The First File
		loc file1 = file1Tuple.first;
		list[str] lines1 = removeComments(readFile(file1));
		int file1Size = size(lines1);
		
		for(loc file2 <- file1Tuple.sec){
			//Step 2.2: Read The Second File
			
			bool SameFile = file1 == file2;
			list[str] lines2 = removeComments(readFile(file2));
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
					duplicatedLines = duplicatedLines + (tempi - i);
					//Set to false again so the lines are not matched anymore
					tempi = i;tempj=j;
					while(boolMat[tempi][tempj]){
						boolMat[tempi][tempj]= false;tempi=tempi+1;tempj=tempj+1;
						if(tempi >= file1Size || tempj >= file2Size) break;
					}				
				}
			}
		}
	}
	return duplicatedLines;

}
//Help for Debugging
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

/* 
	Code Complexity
*/
  
public int codeComplexity(Statement method){
	int count = 1;
	int andOrs = 0;
	visit(method){
		case \if (v1,_) : {count = count + 1 + SearchConditional(v1);}
		case \if (v1,_,_) :{count = count + 1 + SearchConditional(v1);}
		case \while (v1,_) :  {count = count + 1 + SearchConditional(v1);}
		case \case (v1) : {count = count + 1 + SearchConditional(v1);}
		case \for (_,v1,_) : {count = count + 1 + SearchConditional(v1);}
		case \for (_,_,_,_) : count = count + 1;
		case \foreach (_,_,_) : count = count + 1;
		case \do (_,v1) :{count = count + 1 + SearchConditional(v1);}
	}
	return count;	
}

public int SearchConditional(Expression exp){
int count = 0;
visit(exp){
	case \infix(_,op,_,extOp) : {if(op == "||" || op == "&&"){count = count +1 + size(extOp);}}
}
println("SearchConditional = <count>");
return count;
}

/* 
 * LOC
 */
public int countLOCproject(M3 project){
	return (0 | it + countLOC(file) | file <- files(project));
}

public int countLOC(loc meth){
	str method = readFile(meth);
	list[str] lines = removeComments(method);
	return size(lines);	
}

public list[str] removeComments(str string){
	str string2 = replaceStrings(string);
	str string3 = removeMultMultiLineComments2(removeMultMultiLineComments(string2));
	list[str] lines = removeFromList(mapper(split("\n",string3),trim),["","{","}"]);
	//println(lines);
	return lines;	
}

public str replaceStrings(str line){
	return visit(line){
		case /\"([^\\"]*|([\\].))*\"/ => "\"\""
	}
}

public str removeMultMultiLineComments(str line){
	return visit(line){
		case /\/\*.*?\*\//s => ""
		case /^\/\/.*/		=> ""
	}	
}

public str removeMultMultiLineComments2(str line){
	return visit(line){
		//case /\/\*.*?\*\//s => ""
		case /^\/\/.*/		=> ""
	}	
}

public list[str] removeFromList(list[str] Full , list[str] not){
	return [ n | n <- Full, n notin not];
}