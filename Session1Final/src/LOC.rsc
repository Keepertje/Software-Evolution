module LOC

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import Prelude;

int countMethods(M3 project)
{
	return size(methods(project));
}

public int countLOCproject(M3 project){
	return (0 | it + debugTest(it,file,countLOC(file,false)) | file <- filesWithoutUnit(project));
}

public int debugTest(int total, loc file, int Countfile){
	println("<total> of lines read, current file <file>, with length <Countfile>");
	return Countfile;
}


public int countLOC(loc meth,bool bodyOnly){
	println(meth);
	str method = readFile(meth);
	list[str] lines = removeComments(method,bodyOnly);
	return size(lines);	
}

public list[str] removeComments(str string,bool bodyOnly){
	str string2 = replaceStrings(string);
	str string3 = removeMultMultiLineComments2(removeMultMultiLineComments(string));
	list[str] lines = removeFromList(mapper(split("\n",string3),trim),[""]);
	//Don't count starting braces and closing braces
	if(bodyOnly){
	if(lines[0] == "{") lines = delete(lines,0);
	if(lines[(size(lines)-1)] == "}") lines = delete(lines,(size(lines)-1));
	}
	//println(lines);
	return lines;	
}

public str replaceStrings(str line){
	//return visit(line){
	//	case /\"([^\\"]*|([\\].))*\"/ => "\"\""
	//}
	for( /[^\\]<a:\"([^\\"]*|([\\].))*\">/s := line) {
		line = replaceAll(line,a,"\"\"");
	} 
	return line;

	
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

public set[loc] filesWithoutUnit(M3 containment) 
  = {file | file <- files(containment), !contains((file).uri,"java+compilationUnit:///src/smallsql/junit")};
