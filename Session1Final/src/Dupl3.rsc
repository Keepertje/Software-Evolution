module Dupl3

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import LOC;
import IO;
import Prelude;
import util::Math;

//:set profiling true;

map[loc location, list[str] lines] readInFiles = ();
map[loc, map[ int lineNumber, bool found]] Matched = ();
map[loc, map[str, list[int]]] linesMap = ();
int TotalComparison = 13041;
int PERCENTAGECOUNTER = 0;


public int CodeDuplication(M3 project)
{
	linesMap = ();
	Matched = ();
	readInFiles = ();
	list[loc] projFiles = toList(filesWithoutUnit(project));
	
	//Read in the Files
	readInFiles = ( file:removeComments(readFile(file),false) | file <- projFiles, bprintln("Reading File <file>"));
	
	//Set up map for Quick Searching
	linesMap = ( file: ListToMap(readInFiles[file]) | file <- projFiles, bprintln("Mapping File <file>"));
	
	//Set up Matched before to avoid double counting
	Matched = ( file:() | file <- projFiles);
	
	//Count the dupLines in the Files
	return ( 0 | it + dupFileLines(loc1,loc2) | loc1 <- projFiles, loc2 <- projFiles[indexOf(projFiles,loc1)..]);
	
}

public int dupFileLines(loc loc1, loc loc2){
	PERCENTAGECOUNTER +=1;
	if(PERCENTAGECOUNTER % 130 == 0) println(<round(100*(PERCENTAGECOUNTER*1.0)/TotalComparison)>);	
	//Get the readLines
	list[str] lines1 = readInFiles[loc1];
	list[str] lines2 = readInFiles[loc2];
	//Get the Map for loc2
	map[str,list[int]] lines2Map = linesMap[loc2];
	
	int count = 0;
	int sizeFile1 = size(lines1);
	int sizeFile2 = size(lines2);
	
	for(int i <- [0..(sizeFile1-6)]){
		if(lines1[i] in lines2Map){
		count += (0 | it + uniqDuplicates(loc1,loc2,i,j) | j <- lines2Map[lines1[i]], (j+5) < sizeFile2 && (i+5) < sizeFile1 && lines1[i..(i+6)] == lines2[j..(j+6)]);
	}}
	return count;
}


public int uniqDuplicates(loc loc1, loc loc2, int i , int j){
	//Samefile not count diagonal
	if(loc1 == loc2 && i == j) return 0;
	return (0 | it + setMatched(loc1,line) | int line <- [i..i+6], !(line in Matched[loc1])) + 
			(0 | it + setMatched(loc2,line) | int line <- [j..j+6], !(line in Matched[loc2])); 
}

public int setMatched(loc loc1,int line){
	Matched[loc1] += (line:true);
	return 1;
}

public map[str, list[int]] ListToMap(list[str] lines){

	map[str, list[int]] result = ();
	int fileSize = size(lines);
	//Don't count the last 5 lines now duplication start can begin there
	for(int i <- [0..(fileSize-6)]){
		if(lines[i] in result){
			result[lines[i]] += [i];
		}else{
			result += (lines[i]:[i]);
		}
	}
	return result;
}