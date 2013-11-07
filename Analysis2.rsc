module Analysis2

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import IO;
import List;
import String;
import Set;

set[Declaration] ast1 = createAstsFromEclipseProject(|project://Test|,true);
M3 m3project1 = createM3FromEclipseProject(|project://Test|);

int countMethods(M3 project)
{
	return size(methods(project));
}

void AnalyzeMethods(set[Declaration] ast)
{
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

public int calcCC(Statement method){
	int count = 1;
	visit(method){
		case \if(_,_) : count = count +1;
		case \if(_,_,_) : count = count +1;
	}
	return count;
}


public int countLOCproject(M3 project){
	return (0 | it + countLOC(file) | file <- files(project));
}

public int countLOC(loc meth){
	return (meth.end.line - meth.begin.line + 1) - countCommentedOrEmptyLOC(meth);
}

//Does not catch multiLine inside comments!
public int countCommentedOrEmptyLOC(loc meth){
	str method = readFile(meth);
	//Split the lines
	list[str] lines = split("\n",method);
	
	//Remove starting white spaces
	list[str] trimmedLines = mapper(lines,trim);
	
	int count = 0;
	bool multiLineComment = false;
	for(line <- trimmedLines){
		//Stop condition for multiLineComments
		if(/\*\/<a:.*>/ := replaceStrings(line)){
			multiLineComment = false;
			line = a;
		}
		if(multiLineComment)
			count = count + 1;
		else{
			//Replace all the strings to empty to avoid pattern matches inside strings
			switch(replaceStrings(line)){	
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
