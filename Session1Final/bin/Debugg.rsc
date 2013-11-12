module Debugg

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import LOC;
import Prelude;
import util::Math;
import LOC;
import CC;
import Dupl2;

M3 m3project1 = createM3FromEclipseProject(|project://smallsql0.21_src|);
int count = CodeDuplication(m3project1);