module Main

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import Prelude;
import LOC;
import CC;
import Dupl3;

alias matrix = list[list[bool]];
alias methodInfo = list[ tuple [str name, loc src, int LOC, int CC]];
loc trouble = |project://Test/src/Test.java|;
//M3 m3project1 = createM3FromEclipseProject(|project://smallsql0.21_src|);
methodInfo AnalyzeMethods()
{
	set[Declaration] ast = createAstsFromEclipseProject(|project://smallsql0.21_src|,true);
	methodInfo info = [];
	visit(ast){
		case m:method(v1,v2,v3,v4,v5) :{
			//println("name = <v2>");
			//println("src = <v5 @ src>"); 
			int LOCS = countLOC(v5 @ src,true);
			int CC = codeComplexity(v5);
			//println("LOC = <LOCS>");
			info = info + <v2,v5 @ src, LOCS, CC>;
			//println("CC = <CC>");			
		}
		case c:constructor(v1,v2,v3,v4) : {
			int LOCS = countLOC(v4 @ src);
			int CC = codeComplexity(v4);
			//println("LOC = <LOCS>");
			info = info + <v1,v4 @ src, LOCS, CC>;
		}
	}
	return info;	
}


public methodInfo getMethods(methodInfo info,loc location)
{
	return ([] | it + <a,b,c,d> | <a,b,c,d> <- info, b.uri == location.uri);
}

public methodInfo getSubMethods(methodInfo info,loc location)
{
	return ([] | it + <a,b,c,d> | <a,b,c,d> <- info, contains(b.uri,(location.parent).uri));
}

