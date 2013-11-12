module CC

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import Prelude;

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
//println("SearchConditional = <count>");
return count;
}