module Analysis3

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import IO;
import List;
import String;
import Set;


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
			//int CC = calcCC(v5);
			println("LOC = <LOCS>");			
		}
	}	
}

public int countLOCproject(M3 project){
	return (0 | it + countLOC(file) | file <- files(project));
}

public int countLOC(loc meth){
	return (meth.end.line - meth.begin.line + 1) - countCommentedOrEmptyLOC(meth);
}

public int countCommentedOrEmptyLOC(loc meth){
	str method = readFile(meth);
	//Split the lines
	list[str] lines = split("\n",method);
	
	//Remove starting white spaces & Multiple line quotes on one single line & Any strings in the file
	list[str] adjLines1 = mapper(lines,replaceStrings);
	list[str] adjLines2 = mapper(adjLines1,removeMultMultiLineComments);
	list[str] adjLines3 = mapper(adjLines2,trim);
	
	int count = 0;
	bool multiLineComment = false;
	for(line <- adjLines3){
		println(line);
		//Stop condition for multiLineComments
		if(/\*\/<a:.*>/ := line){
			multiLineComment = false;
			line = a;
		}
		if(multiLineComment)
			count = count + 1;
		else{
			//Replace all the strings to empty to avoid pattern matches inside strings
			switch(line){	
			//Start of a multiLine Comment (BEGINNING)
			case /^\/\*.*/				: {count = count + 1; multiLineComment = true;}
			//Start of a multiLine Comment (after some source code)
			case /\/\*.*/				: {multiLineComment = true;}
			//Start of a singleLine Comment 
			case /^\/\/.*/				: {count = count + 1;}
			//Empty line
			case ""						: {count = count + 1;}
			}
		}
	}
	return count;
}

public str replaceStrings(str line){
	return visit(line){
		case /\"([^\\"]*|([\\].))*\"/ => "\"\""
	}
}

public str removeMultMultiLineComments(str line){
	return visit(line){
		case /\/\*(?)\*\//m => ""
		case /^\/\/.*/		=> ""
	}
}